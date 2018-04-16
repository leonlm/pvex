Ext.define('PVE.form.CPUModelSelector', {
    extend: 'PVE.form.KVComboBox',
    alias: ['widget.CPUModelSelector'],
    comboItems: [
	['__default__', PVE.Utils.defaultText + ' (kvm64)'],
	['486', '486'],
	['athlon', 'athlon'],
	['core2duo', 'core2duo'],
	['coreduo', 'coreduo'],
	['kvm32', 'kvm32'],
	['kvm64', 'kvm64'],
	['pentium', 'pentium'],
	['pentium2', 'pentium2'],
	['pentium3', 'pentium3'],
	['phenom', 'phenom'],
	['qemu32', 'qemu32'],
	['qemu64', 'qemu64'],
	['Conroe', 'Conroe'],
	['Penryn', 'Penryn'],
	['Nehalem', 'Nehalem'],
	['Westmere', 'Westmere'],
	['SandyBridge', 'SandyBridge'],
	['IvyBridge', 'IvyBridge'],
	['Haswell', 'Haswell'],
	['Haswell-noTSX','Haswell-noTSX'],
	['Broadwell', 'Broadwell'],
	['Broadwell-noTSX','Broadwell-noTSX'],
	['Skylake-Client','Skylake-Client'],
	['Opteron_G1', 'Opteron_G1'],
	['Opteron_G2', 'Opteron_G2'],
	['Opteron_G3', 'Opteron_G3'],
	['Opteron_G4', 'Opteron_G4'],
	['Opteron_G5', 'Opteron_G5'],
	['host', 'host']

    ]
});
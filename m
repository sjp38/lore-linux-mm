Received: by py-out-1112.google.com with SMTP id n24so446312pyh.20
        for <linux-mm@kvack.org>; Thu, 03 Jul 2008 07:27:19 -0700 (PDT)
Message-ID: <486CE1A7.4030009@gmail.com>
Date: Thu, 03 Jul 2008 16:26:47 +0200
From: Jiri Slaby <jirislaby@gmail.com>
MIME-Version: 1.0
Subject: WARNING at acpi/.../utmisc.c:1043 [Was: 2.6.26-rc8-mm1]
References: <20080703020236.adaa51fa.akpm@linux-foundation.org>
In-Reply-To: <20080703020236.adaa51fa.akpm@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, ak@linux.intel.com, linux-acpi@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Andrew Morton napsal(a):
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.26-rc8/2.6.26-rc8-mm1/

Running this in qemu shows up these 3 warnings while booting (It's tainted 
due to previous MTRR warning which was there for ever):

PCI: Using configuration type 1 for base access
------------[ cut here ]------------
WARNING: at /home/latest/xxx/drivers/acpi/utilities/utmisc.c:1043 
acpi_ut_exception+0x3c/0xb9()
Modules linked in:
Pid: 1, comm: swapper Tainted: G       AW 2.6.26-rc8-mm1-nohz #7

Call Trace:
  [<ffffffff8023c2df>] warn_on_slowpath+0x5f/0x90
  [<ffffffff803674c1>] ? acpi_ns_evaluate+0x39/0x1c4
  [<ffffffff8036719c>] ? acpi_evaluate_object+0x1ea/0x1fe
  [<ffffffff803736a4>] ? ec_parse_io_ports+0x0/0x34
  [<ffffffff8036f32e>] ? acpi_ut_remove_reference+0x2d/0x31
  [<ffffffff80366a55>] ? acpi_ns_search_one_scope+0x1d/0x46
  [<ffffffff80366b3a>] ? acpi_ns_search_and_enter+0xbc/0x18a
  [<ffffffff8036e24e>] acpi_ut_exception+0x3c/0xb9
  [<ffffffff8052b1c0>] ? _spin_unlock_irqrestore+0x30/0x40
  [<ffffffff80257a74>] ? up+0x34/0x50
  [<ffffffff8052b1c0>] ? _spin_unlock_irqrestore+0x30/0x40
  [<ffffffff80257acc>] ? down_timeout+0x3c/0x60
  [<ffffffff8052b1c0>] ? _spin_unlock_irqrestore+0x30/0x40
  [<ffffffff80257a74>] ? up+0x34/0x50
  [<ffffffff803737f7>] ? acpi_ec_gpe_handler+0x0/0x109
  [<ffffffff8035e475>] acpi_install_gpe_handler+0x12c/0x13a
  [<ffffffff8070f829>] ? acpi_init+0x0/0x221
  [<ffffffff80374121>] ec_install_handlers+0x2e/0x9c
  [<ffffffff8070fe1e>] acpi_ec_ecdt_probe+0xee/0x124
  [<ffffffff8070f8ae>] acpi_init+0x85/0x221
  [<ffffffff8033a3db>] ? kset_create_and_add+0x6b/0xa0
  [<ffffffff8034b2e0>] ? pci_slot_init+0x0/0x50
  [<ffffffff806f95b7>] do_one_initcall+0x35/0x15d
  [<ffffffff802719f8>] ? register_irq_proc+0xe8/0x110
  [<ffffffff802f0000>] ? __inode_dir_notify+0x30/0xf0
  [<ffffffff806f987a>] kernel_init+0x19b/0x1a6
  [<ffffffff802396f7>] ? schedule_tail+0x27/0x60
  [<ffffffff8020c788>] child_rip+0xa/0x12
  [<ffffffff806f96df>] ? kernel_init+0x0/0x1a6
  [<ffffffff8020c77e>] ? child_rip+0x0/0x12

---[ end trace 4eaa2a86a8e2da22 ]---
ACPI Exception (evxface-0645): AE_BAD_PARAMETER, Installing notify handler 
failed [20080609]
ACPI: Interpreter enabled







ACPI: EC: driver started in poll mode
------------[ cut here ]------------
WARNING: at /home/latest/xxx/drivers/acpi/utilities/utmisc.c:1043 
acpi_ut_exception+0x3c/0xb9()
Modules linked in:
Pid: 1, comm: swapper Tainted: G       AW 2.6.26-rc8-mm1-nohz #7

Call Trace:
  [<ffffffff8023c2df>] warn_on_slowpath+0x5f/0x90
  [<ffffffff80340963>] ? __const_udelay+0x43/0x50
  [<ffffffff8023c61e>] ? __call_console_drivers+0x6e/0x90
  [<ffffffff80257a74>] ? up+0x34/0x50
  [<ffffffff8023cc04>] ? release_console_sem+0x1e4/0x1f0
  [<ffffffff8036e24e>] acpi_ut_exception+0x3c/0xb9
  [<ffffffff80338d82>] ? idr_get_empty_slot+0x102/0x2b0
  [<ffffffff80257acc>] ? down_timeout+0x3c/0x60
  [<ffffffff80257acc>] ? down_timeout+0x3c/0x60
  [<ffffffff80257a74>] ? up+0x34/0x50
  [<ffffffff803737f7>] ? acpi_ec_gpe_handler+0x0/0x109
  [<ffffffff8035e475>] acpi_install_gpe_handler+0x12c/0x13a
  [<ffffffff80374121>] ec_install_handlers+0x2e/0x9c
  [<ffffffff803741af>] acpi_ec_start+0x20/0x44
  [<ffffffff80371c07>] acpi_start_single_object+0x2a/0x54
  [<ffffffff80372341>] acpi_device_probe+0x78/0x8c
  [<ffffffff803b2892>] driver_probe_device+0xa2/0x1e0
  [<ffffffff803b2a5b>] __driver_attach+0x8b/0x90
  [<ffffffff803b29d0>] ? __driver_attach+0x0/0x90
  [<ffffffff803b204b>] bus_for_each_dev+0x6b/0xa0
  [<ffffffff80339dca>] ? kobject_get+0x1a/0x30
  [<ffffffff803b26dc>] driver_attach+0x1c/0x20
  [<ffffffff803b18d8>] bus_add_driver+0x208/0x280
  [<ffffffff8070fc94>] ? acpi_ec_init+0x0/0x61
  [<ffffffff803b2c40>] driver_register+0x70/0x160
  [<ffffffff8070fc94>] ? acpi_ec_init+0x0/0x61
  [<ffffffff8037264a>] acpi_bus_register_driver+0x3e/0x40
  [<ffffffff8070fcd3>] acpi_ec_init+0x3f/0x61
  [<ffffffff806f95b7>] do_one_initcall+0x35/0x15d
  [<ffffffff802719f8>] ? register_irq_proc+0xe8/0x110
  [<ffffffff802f0000>] ? __inode_dir_notify+0x30/0xf0
  [<ffffffff806f987a>] kernel_init+0x19b/0x1a6
  [<ffffffff802396f7>] ? schedule_tail+0x27/0x60
  [<ffffffff8020c788>] child_rip+0xa/0x12
  [<ffffffff806f96df>] ? kernel_init+0x0/0x1a6
  [<ffffffff8020c77e>] ? child_rip+0x0/0x12

---[ end trace 4eaa2a86a8e2da22 ]---
ACPI Exception (evxface-0645): AE_BAD_PARAMETER, Installing notify handler 
failed [20080609]
ACPI: PCI Root Bridge [PCI0] (0000:00)









processor ACPI0007:00: registered as cooling_device0
------------[ cut here ]------------
WARNING: at /home/latest/xxx/drivers/acpi/utilities/utmisc.c:1043 
acpi_ut_exception+0x3c/0xb9()
Modules linked in:
Pid: 1, comm: swapper Tainted: G       AW 2.6.26-rc8-mm1-nohz #7

Call Trace:
  [<ffffffff8023c2df>] warn_on_slowpath+0x5f/0x90
  [<ffffffff80257a74>] ? up+0x34/0x50
  [<ffffffff803576d6>] ? acpi_os_release_object+0x9/0xd
  [<ffffffff8036f92c>] ? acpi_ut_delete_object_desc+0x48/0x4c
  [<ffffffff8036f103>] ? acpi_ut_delete_internal_obj+0x167/0x16f
  [<ffffffff8036f162>] ? acpi_ut_update_ref_count+0x57/0xa3
  [<ffffffff8036f2a5>] ? acpi_ut_update_object_reference+0xf7/0x153
  [<ffffffff8036e24e>] acpi_ut_exception+0x3c/0xb9
  [<ffffffff80357912>] ? acpi_os_signal_semaphore+0x23/0x27
  [<ffffffff8036719c>] ? acpi_evaluate_object+0x1ea/0x1fe
  [<ffffffff8036f103>] ? acpi_ut_delete_internal_obj+0x167/0x16f
  [<ffffffff803582e2>] ? acpi_evaluate_integer+0xbf/0xd1
  [<ffffffff8037cbb6>] acpi_thermal_trips_update+0x6a/0x56c
  [<ffffffff8036719c>] ? acpi_evaluate_object+0x1ea/0x1fe
  [<ffffffff802fe7c0>] ? sysfs_ilookup_test+0x0/0x20
  [<ffffffff8052b27e>] ? _spin_unlock+0x2e/0x40
  [<ffffffff803582e2>] ? acpi_evaluate_integer+0xbf/0xd1
  [<ffffffff8037d9e8>] acpi_thermal_add+0x3cf/0x43e
  [<ffffffff80372312>] acpi_device_probe+0x49/0x8c
  [<ffffffff803b2892>] driver_probe_device+0xa2/0x1e0
  [<ffffffff803b2a5b>] __driver_attach+0x8b/0x90
  [<ffffffff803b29d0>] ? __driver_attach+0x0/0x90
  [<ffffffff803b204b>] bus_for_each_dev+0x6b/0xa0
  [<ffffffff80339dca>] ? kobject_get+0x1a/0x30
  [<ffffffff803b26dc>] driver_attach+0x1c/0x20
  [<ffffffff803b18d8>] bus_add_driver+0x208/0x280
  [<ffffffff8071032f>] ? acpi_thermal_init+0x0/0x83
  [<ffffffff803b2c40>] driver_register+0x70/0x160
  [<ffffffff8071032f>] ? acpi_thermal_init+0x0/0x83
  [<ffffffff8037264a>] acpi_bus_register_driver+0x3e/0x40
  [<ffffffff80710390>] acpi_thermal_init+0x61/0x83
  [<ffffffff806f95b7>] do_one_initcall+0x35/0x15d
  [<ffffffff802719f8>] ? register_irq_proc+0xe8/0x110
  [<ffffffff802f0000>] ? __inode_dir_notify+0x30/0xf0
  [<ffffffff806f987a>] kernel_init+0x19b/0x1a6
  [<ffffffff802396f7>] ? schedule_tail+0x27/0x60
  [<ffffffff8020c788>] child_rip+0xa/0x12
  [<ffffffff806f96df>] ? kernel_init+0x0/0x1a6
  [<ffffffff8020c77e>] ? child_rip+0x0/0x12

---[ end trace 4eaa2a86a8e2da22 ]---
ACPI Exception (thermal-0377): AE_OK, No or invalid critical threshold 
[20080609]
Real Time Clock Driver v1.12ac

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 08E206B0005
	for <linux-mm@kvack.org>; Mon, 25 Feb 2013 20:04:42 -0500 (EST)
Subject: Re: [PATCH v2] mm: break circular include from linux/mmzone.h
From: li guang <lig.fnst@cn.fujitsu.com>
In-Reply-To: <1361168830-13130-1-git-send-email-lig.fnst@cn.fujitsu.com>
References: <1361168830-13130-1-git-send-email-lig.fnst@cn.fujitsu.com>
Date: Tue, 26 Feb 2013 09:03:46 +0800
Message-ID: <1361840626.2262.26.camel@liguang.fnst.cn.fujitsu.com>
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org

ping ...

did any one find build errors after applying this patch?

=E5=9C=A8 2013-02-18=E4=B8=80=E7=9A=84 14:27 +0800=EF=BC=8Cliguang=E5=86=99=
=E9=81=93=EF=BC=9A
> linux/mmzone.h included linux/memory_hotplug.h,
> and linux/memory_hotplug.h also included
> linux/mmzone.h, so there's a bad cirlular.
>=20
> these are quite mechanical changes by a simple
> script, I've tested for ARCH x86,arm,mips,
> may someone help to test more.
>=20
> Signed-off-by: liguang <lig.fnst@cn.fujitsu.com>
> ---
> many thanks to Fengguang Wu <fengguang.wu@intel.com>
> and Stephen Rothwell <sfr@canb.auug.org.au> who
> find build errors for v1,
> and also David Rientjes <rientjes@google.com>
> who try to fix v1.
> I'm really regretful for the bold v1 which
> lack of consideration and test.
>=20
>  arch/alpha/include/asm/pgalloc.h              |    1 +
>  arch/alpha/include/asm/pgtable.h              |    1 +
>  arch/avr32/mm/init.c                          |    1 +
>  arch/cris/arch-v10/mm/init.c                  |    1 +
>  arch/cris/arch-v32/mm/init.c                  |    1 +
>  arch/hexagon/kernel/setup.c                   |    1 +
>  arch/ia64/kernel/acpi.c                       |    1 +
>  arch/ia64/kernel/machine_kexec.c              |    1 +
>  arch/ia64/mm/init.c                           |    1 +
>  arch/ia64/sn/kernel/setup.c                   |    1 +
>  arch/ia64/sn/kernel/sn2/sn2_smp.c             |    1 +
>  arch/m32r/mm/discontig.c                      |    1 +
>  arch/m68k/include/asm/virtconvert.h           |    1 +
>  arch/mips/include/asm/pgtable.h               |    1 +
>  arch/mips/include/asm/sn/mapped_kernel.h      |    1 +
>  arch/mips/sgi-ip27/ip27-hubio.c               |    1 +
>  arch/mips/sgi-ip27/ip27-klnuma.c              |    1 +
>  arch/mips/sgi-ip27/ip27-memory.c              |    1 +
>  arch/mips/sgi-ip27/ip27-nmi.c                 |    1 +
>  arch/mips/sgi-ip27/ip27-reset.c               |    1 +
>  arch/powerpc/mm/numa.c                        |    1 +
>  arch/powerpc/platforms/ps3/spu.c              |    1 +
>  arch/sh/kernel/setup.c                        |    1 +
>  arch/sparc/mm/init_64.c                       |    1 +
>  arch/tile/gxio/kiorpc.c                       |    1 +
>  arch/tile/include/asm/pgalloc.h               |    1 +
>  arch/tile/kernel/pci_gx.c                     |    1 +
>  arch/tile/kernel/setup.c                      |    1 +
>  arch/tile/kernel/stack.c                      |    1 +
>  arch/x86/kernel/acpi/srat.c                   |    1 +
>  arch/x86/kernel/aperture_64.c                 |    1 +
>  arch/x86/kernel/apic/numaq_32.c               |    1 +
>  arch/x86/kernel/probe_roms.c                  |    1 +
>  arch/x86/kernel/setup.c                       |    1 +
>  arch/x86/kernel/topology.c                    |    1 +
>  arch/x86/mm/numa.c                            |    1 +
>  drivers/char/agp/amd64-agp.c                  |    1 +
>  drivers/edac/amd64_edac.h                     |    1 +
>  drivers/edac/i5100_edac.c                     |    1 +
>  drivers/edac/i5400_edac.c                     |    1 +
>  drivers/edac/i7300_edac.c                     |    1 +
>  drivers/edac/i7core_edac.c                    |    1 +
>  drivers/edac/sb_edac.c                        |    1 +
>  drivers/s390/char/sclp_cmd.c                  |    1 +
>  drivers/staging/tidspbridge/core/tiomap3430.c |    1 +
>  drivers/video/vermilion/vermilion.c           |    1 +
>  fs/file.c                                     |    1 +
>  fs/proc/meminfo.c                             |    1 +
>  fs/proc/nommu.c                               |    1 +
>  fs/proc/page.c                                |    1 +
>  include/linux/bootmem.h                       |    1 +
>  include/linux/gfp.h                           |    1 +
>  include/linux/memory_hotplug.h                |    1 -
>  include/linux/mempolicy.h                     |    1 +
>  include/linux/mm.h                            |    1 +
>  include/linux/mmzone.h                        |    2 --
>  include/linux/swap.h                          |    1 +
>  include/linux/topology.h                      |    1 +
>  include/linux/vmstat.h                        |    1 +
>  mm/kmemleak.c                                 |    1 +
>  mm/mlock.c                                    |    1 +
>  mm/mmzone.c                                   |    1 +
>  mm/page_cgroup.c                              |    1 +
>  mm/quicklist.c                                |    1 +
>  mm/sparse-vmemmap.c                           |    1 +
>  mm/sparse.c                                   |    1 +
>  66 files changed, 64 insertions(+), 3 deletions(-)
>=20
> diff --git a/arch/alpha/include/asm/pgalloc.h b/arch/alpha/include/asm/pg=
alloc.h
> index bc2a0da..ab9c10e 100644
> --- a/arch/alpha/include/asm/pgalloc.h
> +++ b/arch/alpha/include/asm/pgalloc.h
> @@ -3,6 +3,7 @@
> =20
>  #include <linux/mm.h>
>  #include <linux/mmzone.h>
> +#include <linux/memory_hotplug.h>
> =20
>  /*     =20
>   * Allocate and free page tables. The xxx_kernel() versions are
> diff --git a/arch/alpha/include/asm/pgtable.h b/arch/alpha/include/asm/pg=
table.h
> index 81a4342..def3f86 100644
> --- a/arch/alpha/include/asm/pgtable.h
> +++ b/arch/alpha/include/asm/pgtable.h
> @@ -11,6 +11,7 @@
>   * in <asm/page.h> (currently 8192).
>   */
>  #include <linux/mmzone.h>
> +#include <linux/memory_hotplug.h>
> =20
>  #include <asm/page.h>
>  #include <asm/processor.h>	/* For TASK_SIZE */
> diff --git a/arch/avr32/mm/init.c b/arch/avr32/mm/init.c
> index 2798c2d..d613273 100644
> --- a/arch/avr32/mm/init.c
> +++ b/arch/avr32/mm/init.c
> @@ -12,6 +12,7 @@
>  #include <linux/swap.h>
>  #include <linux/init.h>
>  #include <linux/mmzone.h>
> +#include <linux/memory_hotplug.h>
>  #include <linux/module.h>
>  #include <linux/bootmem.h>
>  #include <linux/pagemap.h>
> diff --git a/arch/cris/arch-v10/mm/init.c b/arch/cris/arch-v10/mm/init.c
> index e7f8066..b78a637 100644
> --- a/arch/cris/arch-v10/mm/init.c
> +++ b/arch/cris/arch-v10/mm/init.c
> @@ -3,6 +3,7 @@
>   *
>   */
>  #include <linux/mmzone.h>
> +#include <linux/memory_hotplug.h>
>  #include <linux/init.h>
>  #include <linux/bootmem.h>
>  #include <linux/mm.h>
> diff --git a/arch/cris/arch-v32/mm/init.c b/arch/cris/arch-v32/mm/init.c
> index 3deca52..d04b2db 100644
> --- a/arch/cris/arch-v32/mm/init.c
> +++ b/arch/cris/arch-v32/mm/init.c
> @@ -7,6 +7,7 @@
>   *            Tobias Anderberg <tobiasa@axis.com>, CRISv32 port.
>   */
>  #include <linux/mmzone.h>
> +#include <linux/memory_hotplug.h>
>  #include <linux/init.h>
>  #include <linux/bootmem.h>
>  #include <linux/mm.h>
> diff --git a/arch/hexagon/kernel/setup.c b/arch/hexagon/kernel/setup.c
> index 94a3878..b376620 100644
> --- a/arch/hexagon/kernel/setup.c
> +++ b/arch/hexagon/kernel/setup.c
> @@ -21,6 +21,7 @@
>  #include <linux/init.h>
>  #include <linux/bootmem.h>
>  #include <linux/mmzone.h>
> +#include <linux/memory_hotplug.h>
>  #include <linux/mm.h>
>  #include <linux/seq_file.h>
>  #include <linux/console.h>
> diff --git a/arch/ia64/kernel/acpi.c b/arch/ia64/kernel/acpi.c
> index 335eb07..52e6061 100644
> --- a/arch/ia64/kernel/acpi.c
> +++ b/arch/ia64/kernel/acpi.c
> @@ -43,6 +43,7 @@
>  #include <linux/acpi.h>
>  #include <linux/efi.h>
>  #include <linux/mmzone.h>
> +#include <linux/memory_hotplug.h>
>  #include <linux/nodemask.h>
>  #include <linux/slab.h>
>  #include <acpi/processor.h>
> diff --git a/arch/ia64/kernel/machine_kexec.c b/arch/ia64/kernel/machine_=
kexec.c
> index 5151a64..2ba502d 100644
> --- a/arch/ia64/kernel/machine_kexec.c
> +++ b/arch/ia64/kernel/machine_kexec.c
> @@ -17,6 +17,7 @@
>  #include <linux/efi.h>
>  #include <linux/numa.h>
>  #include <linux/mmzone.h>
> +#include <linux/memory_hotplug.h>
> =20
>  #include <asm/numa.h>
>  #include <asm/mmu_context.h>
> diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
> index b755ea9..7d9ab81 100644
> --- a/arch/ia64/mm/init.c
> +++ b/arch/ia64/mm/init.c
> @@ -13,6 +13,7 @@
>  #include <linux/memblock.h>
>  #include <linux/mm.h>
>  #include <linux/mmzone.h>
> +#include <linux/memory_hotplug.h>
>  #include <linux/module.h>
>  #include <linux/personality.h>
>  #include <linux/reboot.h>
> diff --git a/arch/ia64/sn/kernel/setup.c b/arch/ia64/sn/kernel/setup.c
> index f82e7b4..e8229c5 100644
> --- a/arch/ia64/sn/kernel/setup.c
> +++ b/arch/ia64/sn/kernel/setup.c
> @@ -22,6 +22,7 @@
>  #include <linux/irq.h>
>  #include <linux/bootmem.h>
>  #include <linux/mmzone.h>
> +#include <linux/memory_hotplug.h>
>  #include <linux/interrupt.h>
>  #include <linux/acpi.h>
>  #include <linux/compiler.h>
> diff --git a/arch/ia64/sn/kernel/sn2/sn2_smp.c b/arch/ia64/sn/kernel/sn2/=
sn2_smp.c
> index 68c8454..3c4bc24 100644
> --- a/arch/ia64/sn/kernel/sn2/sn2_smp.c
> +++ b/arch/ia64/sn/kernel/sn2/sn2_smp.c
> @@ -17,6 +17,7 @@
>  #include <linux/interrupt.h>
>  #include <linux/irq.h>
>  #include <linux/mmzone.h>
> +#include <linux/memory_hotplug.h>
>  #include <linux/module.h>
>  #include <linux/bitops.h>
>  #include <linux/nodemask.h>
> diff --git a/arch/m32r/mm/discontig.c b/arch/m32r/mm/discontig.c
> index 2c468e8..8ad4de7 100644
> --- a/arch/m32r/mm/discontig.c
> +++ b/arch/m32r/mm/discontig.c
> @@ -9,6 +9,7 @@
>  #include <linux/mm.h>
>  #include <linux/bootmem.h>
>  #include <linux/mmzone.h>
> +#include <linux/memory_hotplug.h>
>  #include <linux/initrd.h>
>  #include <linux/nodemask.h>
>  #include <linux/module.h>
> diff --git a/arch/m68k/include/asm/virtconvert.h b/arch/m68k/include/asm/=
virtconvert.h
> index f35229b..75d4fd3 100644
> --- a/arch/m68k/include/asm/virtconvert.h
> +++ b/arch/m68k/include/asm/virtconvert.h
> @@ -9,6 +9,7 @@
> =20
>  #include <linux/compiler.h>
>  #include <linux/mmzone.h>
> +#include <linux/memory_hotplug.h>
>  #include <asm/setup.h>
>  #include <asm/page.h>
> =20
> diff --git a/arch/mips/include/asm/pgtable.h b/arch/mips/include/asm/pgta=
ble.h
> index ec50d52..6d27dd0 100644
> --- a/arch/mips/include/asm/pgtable.h
> +++ b/arch/mips/include/asm/pgtable.h
> @@ -9,6 +9,7 @@
>  #define _ASM_PGTABLE_H
> =20
>  #include <linux/mmzone.h>
> +#include <linux/memory_hotplug.h>
>  #ifdef CONFIG_32BIT
>  #include <asm/pgtable-32.h>
>  #endif
> diff --git a/arch/mips/include/asm/sn/mapped_kernel.h b/arch/mips/include=
/asm/sn/mapped_kernel.h
> index 721496a..db3fc2b 100644
> --- a/arch/mips/include/asm/sn/mapped_kernel.h
> +++ b/arch/mips/include/asm/sn/mapped_kernel.h
> @@ -6,6 +6,7 @@
>  #define __ASM_SN_MAPPED_KERNEL_H
> =20
>  #include <linux/mmzone.h>
> +#include <linux/memory_hotplug.h>
> =20
>  /*
>   * Note on how mapped kernels work: the text and data section is
> diff --git a/arch/mips/sgi-ip27/ip27-hubio.c b/arch/mips/sgi-ip27/ip27-hu=
bio.c
> index cd0d5b0..0f3689d 100644
> --- a/arch/mips/sgi-ip27/ip27-hubio.c
> +++ b/arch/mips/sgi-ip27/ip27-hubio.c
> @@ -9,6 +9,7 @@
>  #include <linux/bitops.h>
>  #include <linux/string.h>
>  #include <linux/mmzone.h>
> +#include <linux/memory_hotplug.h>
>  #include <asm/sn/addrs.h>
>  #include <asm/sn/arch.h>
>  #include <asm/sn/hub.h>
> diff --git a/arch/mips/sgi-ip27/ip27-klnuma.c b/arch/mips/sgi-ip27/ip27-k=
lnuma.c
> index 1d1919a..c1b576e 100644
> --- a/arch/mips/sgi-ip27/ip27-klnuma.c
> +++ b/arch/mips/sgi-ip27/ip27-klnuma.c
> @@ -6,6 +6,7 @@
>  #include <linux/init.h>
>  #include <linux/mm.h>
>  #include <linux/mmzone.h>
> +#include <linux/memory_hotplug.h>
>  #include <linux/kernel.h>
>  #include <linux/nodemask.h>
>  #include <linux/string.h>
> diff --git a/arch/mips/sgi-ip27/ip27-memory.c b/arch/mips/sgi-ip27/ip27-m=
emory.c
> index cd8fcab..12cda13 100644
> --- a/arch/mips/sgi-ip27/ip27-memory.c
> +++ b/arch/mips/sgi-ip27/ip27-memory.c
> @@ -15,6 +15,7 @@
>  #include <linux/memblock.h>
>  #include <linux/mm.h>
>  #include <linux/mmzone.h>
> +#include <linux/memory_hotplug.h>
>  #include <linux/module.h>
>  #include <linux/nodemask.h>
>  #include <linux/swap.h>
> diff --git a/arch/mips/sgi-ip27/ip27-nmi.c b/arch/mips/sgi-ip27/ip27-nmi.=
c
> index 005c29e..82e7d21 100644
> --- a/arch/mips/sgi-ip27/ip27-nmi.c
> +++ b/arch/mips/sgi-ip27/ip27-nmi.c
> @@ -1,5 +1,6 @@
>  #include <linux/kernel.h>
>  #include <linux/mmzone.h>
> +#include <linux/memory_hotplug.h>
>  #include <linux/nodemask.h>
>  #include <linux/spinlock.h>
>  #include <linux/smp.h>
> diff --git a/arch/mips/sgi-ip27/ip27-reset.c b/arch/mips/sgi-ip27/ip27-re=
set.c
> index f347bc6..68e9c01 100644
> --- a/arch/mips/sgi-ip27/ip27-reset.c
> +++ b/arch/mips/sgi-ip27/ip27-reset.c
> @@ -13,6 +13,7 @@
>  #include <linux/timer.h>
>  #include <linux/smp.h>
>  #include <linux/mmzone.h>
> +#include <linux/memory_hotplug.h>
>  #include <linux/nodemask.h>
>  #include <linux/pm.h>
> =20
> diff --git a/arch/powerpc/mm/numa.c b/arch/powerpc/mm/numa.c
> index bba87ca..1cf7dbf 100644
> --- a/arch/powerpc/mm/numa.c
> +++ b/arch/powerpc/mm/numa.c
> @@ -13,6 +13,7 @@
>  #include <linux/init.h>
>  #include <linux/mm.h>
>  #include <linux/mmzone.h>
> +#include <linux/memory_hotplug.h>
>  #include <linux/export.h>
>  #include <linux/nodemask.h>
>  #include <linux/cpu.h>
> diff --git a/arch/powerpc/platforms/ps3/spu.c b/arch/powerpc/platforms/ps=
3/spu.c
> index e17fa14..e917401 100644
> --- a/arch/powerpc/platforms/ps3/spu.c
> +++ b/arch/powerpc/platforms/ps3/spu.c
> @@ -22,6 +22,7 @@
>  #include <linux/init.h>
>  #include <linux/slab.h>
>  #include <linux/mmzone.h>
> +#include <linux/memory_hotplug.h>
>  #include <linux/export.h>
>  #include <linux/io.h>
>  #include <linux/mm.h>
> diff --git a/arch/sh/kernel/setup.c b/arch/sh/kernel/setup.c
> index ebe7a7d..c1943a2 100644
> --- a/arch/sh/kernel/setup.c
> +++ b/arch/sh/kernel/setup.c
> @@ -25,6 +25,7 @@
>  #include <linux/err.h>
>  #include <linux/crash_dump.h>
>  #include <linux/mmzone.h>
> +#include <linux/memory_hotplug.h>
>  #include <linux/clk.h>
>  #include <linux/delay.h>
>  #include <linux/platform_device.h>
> diff --git a/arch/sparc/mm/init_64.c b/arch/sparc/mm/init_64.c
> index c3b7242..db4472d 100644
> --- a/arch/sparc/mm/init_64.c
> +++ b/arch/sparc/mm/init_64.c
> @@ -25,6 +25,7 @@
>  #include <linux/percpu.h>
>  #include <linux/memblock.h>
>  #include <linux/mmzone.h>
> +#include <linux/memory_hotplug.h>
>  #include <linux/gfp.h>
> =20
>  #include <asm/head.h>
> diff --git a/arch/tile/gxio/kiorpc.c b/arch/tile/gxio/kiorpc.c
> index c8096aa..6a1290f 100644
> --- a/arch/tile/gxio/kiorpc.c
> +++ b/arch/tile/gxio/kiorpc.c
> @@ -15,6 +15,7 @@
>   */
> =20
>  #include <linux/mmzone.h>
> +#include <linux/memory_hotplug.h>
>  #include <linux/module.h>
>  #include <linux/io.h>
>  #include <gxio/iorpc_globals.h>
> diff --git a/arch/tile/include/asm/pgalloc.h b/arch/tile/include/asm/pgal=
loc.h
> index 1b90250..b69352e 100644
> --- a/arch/tile/include/asm/pgalloc.h
> +++ b/arch/tile/include/asm/pgalloc.h
> @@ -18,6 +18,7 @@
>  #include <linux/threads.h>
>  #include <linux/mm.h>
>  #include <linux/mmzone.h>
> +#include <linux/memory_hotplug.h>
>  #include <asm/fixmap.h>
>  #include <asm/page.h>
>  #include <hv/hypervisor.h>
> diff --git a/arch/tile/kernel/pci_gx.c b/arch/tile/kernel/pci_gx.c
> index 1142563..41dae72 100644
> --- a/arch/tile/kernel/pci_gx.c
> +++ b/arch/tile/kernel/pci_gx.c
> @@ -14,6 +14,7 @@
> =20
>  #include <linux/kernel.h>
>  #include <linux/mmzone.h>
> +#include <linux/memory_hotplug.h>
>  #include <linux/pci.h>
>  #include <linux/delay.h>
>  #include <linux/string.h>
> diff --git a/arch/tile/kernel/setup.c b/arch/tile/kernel/setup.c
> index 6a649a4..17b2622 100644
> --- a/arch/tile/kernel/setup.c
> +++ b/arch/tile/kernel/setup.c
> @@ -15,6 +15,7 @@
>  #include <linux/sched.h>
>  #include <linux/kernel.h>
>  #include <linux/mmzone.h>
> +#include <linux/memory_hotplug.h>
>  #include <linux/bootmem.h>
>  #include <linux/module.h>
>  #include <linux/node.h>
> diff --git a/arch/tile/kernel/stack.c b/arch/tile/kernel/stack.c
> index b2f44c2..96f2585 100644
> --- a/arch/tile/kernel/stack.c
> +++ b/arch/tile/kernel/stack.c
> @@ -21,6 +21,7 @@
>  #include <linux/stacktrace.h>
>  #include <linux/uaccess.h>
>  #include <linux/mmzone.h>
> +#include <linux/memory_hotplug.h>
>  #include <linux/dcache.h>
>  #include <linux/fs.h>
>  #include <asm/backtrace.h>
> diff --git a/arch/x86/kernel/acpi/srat.c b/arch/x86/kernel/acpi/srat.c
> index 0a4d7ee..e70d084 100644
> --- a/arch/x86/kernel/acpi/srat.c
> +++ b/arch/x86/kernel/acpi/srat.c
> @@ -12,6 +12,7 @@
>  #include <linux/kernel.h>
>  #include <linux/acpi.h>
>  #include <linux/mmzone.h>
> +#include <linux/memory_hotplug.h>
>  #include <linux/bitmap.h>
>  #include <linux/module.h>
>  #include <linux/topology.h>
> diff --git a/arch/x86/kernel/aperture_64.c b/arch/x86/kernel/aperture_64.=
c
> index d5fd66f..395493f 100644
> --- a/arch/x86/kernel/aperture_64.c
> +++ b/arch/x86/kernel/aperture_64.c
> @@ -15,6 +15,7 @@
>  #include <linux/init.h>
>  #include <linux/memblock.h>
>  #include <linux/mmzone.h>
> +#include <linux/memory_hotplug.h>
>  #include <linux/pci_ids.h>
>  #include <linux/pci.h>
>  #include <linux/bitops.h>
> diff --git a/arch/x86/kernel/apic/numaq_32.c b/arch/x86/kernel/apic/numaq=
_32.c
> index d661ee9..303c7db 100644
> --- a/arch/x86/kernel/apic/numaq_32.c
> +++ b/arch/x86/kernel/apic/numaq_32.c
> @@ -31,6 +31,7 @@
>  #include <linux/cpumask.h>
>  #include <linux/kernel.h>
>  #include <linux/mmzone.h>
> +#include <linux/memory_hotplug.h>
>  #include <linux/module.h>
>  #include <linux/string.h>
>  #include <linux/init.h>
> diff --git a/arch/x86/kernel/probe_roms.c b/arch/x86/kernel/probe_roms.c
> index d5f15c3..b89faa1 100644
> --- a/arch/x86/kernel/probe_roms.c
> +++ b/arch/x86/kernel/probe_roms.c
> @@ -2,6 +2,7 @@
>  #include <linux/mm.h>
>  #include <linux/uaccess.h>
>  #include <linux/mmzone.h>
> +#include <linux/memory_hotplug.h>
>  #include <linux/ioport.h>
>  #include <linux/seq_file.h>
>  #include <linux/console.h>
> diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
> index 00f6c14..ba9488a 100644
> --- a/arch/x86/kernel/setup.c
> +++ b/arch/x86/kernel/setup.c
> @@ -24,6 +24,7 @@
>  #include <linux/sched.h>
>  #include <linux/mm.h>
>  #include <linux/mmzone.h>
> +#include <linux/memory_hotplug.h>
>  #include <linux/screen_info.h>
>  #include <linux/ioport.h>
>  #include <linux/acpi.h>
> diff --git a/arch/x86/kernel/topology.c b/arch/x86/kernel/topology.c
> index 6e60b5f..153b049 100644
> --- a/arch/x86/kernel/topology.c
> +++ b/arch/x86/kernel/topology.c
> @@ -28,6 +28,7 @@
>  #include <linux/nodemask.h>
>  #include <linux/export.h>
>  #include <linux/mmzone.h>
> +#include <linux/memory_hotplug.h>
>  #include <linux/init.h>
>  #include <linux/smp.h>
>  #include <linux/irq.h>
> diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
> index 870ca6b..315bda4 100644
> --- a/arch/x86/mm/numa.c
> +++ b/arch/x86/mm/numa.c
> @@ -6,6 +6,7 @@
>  #include <linux/bootmem.h>
>  #include <linux/memblock.h>
>  #include <linux/mmzone.h>
> +#include <linux/memory_hotplug.h>
>  #include <linux/ctype.h>
>  #include <linux/module.h>
>  #include <linux/nodemask.h>
> diff --git a/drivers/char/agp/amd64-agp.c b/drivers/char/agp/amd64-agp.c
> index d79d692..c279a77 100644
> --- a/drivers/char/agp/amd64-agp.c
> +++ b/drivers/char/agp/amd64-agp.c
> @@ -13,6 +13,7 @@
>  #include <linux/init.h>
>  #include <linux/agp_backend.h>
>  #include <linux/mmzone.h>
> +#include <linux/memory_hotplug.h>
>  #include <asm/page.h>		/* PAGE_SIZE */
>  #include <asm/e820.h>
>  #include <asm/amd_nb.h>
> diff --git a/drivers/edac/amd64_edac.h b/drivers/edac/amd64_edac.h
> index e864f40..c27d3ed 100644
> --- a/drivers/edac/amd64_edac.h
> +++ b/drivers/edac/amd64_edac.h
> @@ -69,6 +69,7 @@
>  #include <linux/pci_ids.h>
>  #include <linux/slab.h>
>  #include <linux/mmzone.h>
> +#include <linux/memory_hotplug.h>
>  #include <linux/edac.h>
>  #include <asm/msr.h>
>  #include "edac_core.h"
> diff --git a/drivers/edac/i5100_edac.c b/drivers/edac/i5100_edac.c
> index d6955b2..7de1bda 100644
> --- a/drivers/edac/i5100_edac.c
> +++ b/drivers/edac/i5100_edac.c
> @@ -27,6 +27,7 @@
>  #include <linux/edac.h>
>  #include <linux/delay.h>
>  #include <linux/mmzone.h>
> +#include <linux/memory_hotplug.h>
> =20
>  #include "edac_core.h"
> =20
> diff --git a/drivers/edac/i5400_edac.c b/drivers/edac/i5400_edac.c
> index 0a05bbc..8a0f323 100644
> --- a/drivers/edac/i5400_edac.c
> +++ b/drivers/edac/i5400_edac.c
> @@ -31,6 +31,7 @@
>  #include <linux/slab.h>
>  #include <linux/edac.h>
>  #include <linux/mmzone.h>
> +#include <linux/memory_hotplug.h>
> =20
>  #include "edac_core.h"
> =20
> diff --git a/drivers/edac/i7300_edac.c b/drivers/edac/i7300_edac.c
> index 087c27b..987aa5b 100644
> --- a/drivers/edac/i7300_edac.c
> +++ b/drivers/edac/i7300_edac.c
> @@ -25,6 +25,7 @@
>  #include <linux/slab.h>
>  #include <linux/edac.h>
>  #include <linux/mmzone.h>
> +#include <linux/memory_hotplug.h>
> =20
>  #include "edac_core.h"
> =20
> diff --git a/drivers/edac/i7core_edac.c b/drivers/edac/i7core_edac.c
> index e213d03..65c70e2 100644
> --- a/drivers/edac/i7core_edac.c
> +++ b/drivers/edac/i7core_edac.c
> @@ -34,6 +34,7 @@
>  #include <linux/dmi.h>
>  #include <linux/edac.h>
>  #include <linux/mmzone.h>
> +#include <linux/memory_hotplug.h>
>  #include <linux/smp.h>
>  #include <asm/mce.h>
>  #include <asm/processor.h>
> diff --git a/drivers/edac/sb_edac.c b/drivers/edac/sb_edac.c
> index da7e298..192cacd 100644
> --- a/drivers/edac/sb_edac.c
> +++ b/drivers/edac/sb_edac.c
> @@ -18,6 +18,7 @@
>  #include <linux/delay.h>
>  #include <linux/edac.h>
>  #include <linux/mmzone.h>
> +#include <linux/memory_hotplug.h>
>  #include <linux/smp.h>
>  #include <linux/bitmap.h>
>  #include <linux/math64.h>
> diff --git a/drivers/s390/char/sclp_cmd.c b/drivers/s390/char/sclp_cmd.c
> index c44d13f..f87e181 100644
> --- a/drivers/s390/char/sclp_cmd.c
> +++ b/drivers/s390/char/sclp_cmd.c
> @@ -17,6 +17,7 @@
>  #include <linux/string.h>
>  #include <linux/mm.h>
>  #include <linux/mmzone.h>
> +#include <linux/memory_hotplug.h>
>  #include <linux/memory.h>
>  #include <linux/module.h>
>  #include <linux/platform_device.h>
> diff --git a/drivers/staging/tidspbridge/core/tiomap3430.c b/drivers/stag=
ing/tidspbridge/core/tiomap3430.c
> index f619fb3..c5ad611 100644
> --- a/drivers/staging/tidspbridge/core/tiomap3430.c
> +++ b/drivers/staging/tidspbridge/core/tiomap3430.c
> @@ -23,6 +23,7 @@
>  #include <dspbridge/host_os.h>
>  #include <linux/mm.h>
>  #include <linux/mmzone.h>
> +#include <linux/memory_hotplug.h>
> =20
>  /*  ----------------------------------- DSP/BIOS Bridge */
>  #include <dspbridge/dbdefs.h>
> diff --git a/drivers/video/vermilion/vermilion.c b/drivers/video/vermilio=
n/vermilion.c
> index 0aa516f..7c6f5c4 100644
> --- a/drivers/video/vermilion/vermilion.c
> +++ b/drivers/video/vermilion/vermilion.c
> @@ -40,6 +40,7 @@
>  #include <asm/cacheflush.h>
>  #include <asm/tlbflush.h>
>  #include <linux/mmzone.h>
> +#include <linux/memory_hotplug.h>
> =20
>  /* #define VERMILION_DEBUG */
> =20
> diff --git a/fs/file.c b/fs/file.c
> index 2b3570b..f70e666 100644
> --- a/fs/file.c
> +++ b/fs/file.c
> @@ -11,6 +11,7 @@
>  #include <linux/fs.h>
>  #include <linux/mm.h>
>  #include <linux/mmzone.h>
> +#include <linux/memory_hotplug.h>
>  #include <linux/time.h>
>  #include <linux/sched.h>
>  #include <linux/slab.h>
> diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
> index 80e4645..dc35e61 100644
> --- a/fs/proc/meminfo.c
> +++ b/fs/proc/meminfo.c
> @@ -5,6 +5,7 @@
>  #include <linux/mm.h>
>  #include <linux/mman.h>
>  #include <linux/mmzone.h>
> +#include <linux/memory_hotplug.h>
>  #include <linux/proc_fs.h>
>  #include <linux/quicklist.h>
>  #include <linux/seq_file.h>
> diff --git a/fs/proc/nommu.c b/fs/proc/nommu.c
> index b1822dd..bb67662 100644
> --- a/fs/proc/nommu.c
> +++ b/fs/proc/nommu.c
> @@ -19,6 +19,7 @@
>  #include <linux/proc_fs.h>
>  #include <linux/mm.h>
>  #include <linux/mmzone.h>
> +#include <linux/memory_hotplug.h>
>  #include <linux/pagemap.h>
>  #include <linux/swap.h>
>  #include <linux/smp.h>
> diff --git a/fs/proc/page.c b/fs/proc/page.c
> index b8730d9..a54948f 100644
> --- a/fs/proc/page.c
> +++ b/fs/proc/page.c
> @@ -5,6 +5,7 @@
>  #include <linux/ksm.h>
>  #include <linux/mm.h>
>  #include <linux/mmzone.h>
> +#include <linux/memory_hotplug.h>
>  #include <linux/proc_fs.h>
>  #include <linux/seq_file.h>
>  #include <linux/hugetlb.h>
> diff --git a/include/linux/bootmem.h b/include/linux/bootmem.h
> index 3f778c2..255c5c5 100644
> --- a/include/linux/bootmem.h
> +++ b/include/linux/bootmem.h
> @@ -5,6 +5,7 @@
>  #define _LINUX_BOOTMEM_H
> =20
>  #include <linux/mmzone.h>
> +#include <linux/memory_hotplug.h>
>  #include <asm/dma.h>
> =20
>  /*
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index 0f615eb..2ef7540 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -2,6 +2,7 @@
>  #define __LINUX_GFP_H
> =20
>  #include <linux/mmzone.h>
> +#include <linux/memory_hotplug.h>
>  #include <linux/stddef.h>
>  #include <linux/linkage.h>
>  #include <linux/topology.h>
> diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplu=
g.h
> index 4a45c4e..67b1c56 100644
> --- a/include/linux/memory_hotplug.h
> +++ b/include/linux/memory_hotplug.h
> @@ -1,7 +1,6 @@
>  #ifndef __LINUX_MEMORY_HOTPLUG_H
>  #define __LINUX_MEMORY_HOTPLUG_H
> =20
> -#include <linux/mmzone.h>
>  #include <linux/spinlock.h>
>  #include <linux/notifier.h>
>  #include <linux/bug.h>
> diff --git a/include/linux/mempolicy.h b/include/linux/mempolicy.h
> index 0d7df39..cc0a77a 100644
> --- a/include/linux/mempolicy.h
> +++ b/include/linux/mempolicy.h
> @@ -7,6 +7,7 @@
> =20
>=20
>  #include <linux/mmzone.h>
> +#include <linux/memory_hotplug.h>
>  #include <linux/slab.h>
>  #include <linux/rbtree.h>
>  #include <linux/spinlock.h>
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 66e2f7c..2e99008 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -9,6 +9,7 @@
>  #include <linux/bug.h>
>  #include <linux/list.h>
>  #include <linux/mmzone.h>
> +#include <linux/memory_hotplug.h>
>  #include <linux/rbtree.h>
>  #include <linux/atomic.h>
>  #include <linux/debug_locks.h>
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 73b64a3..4211466 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -758,8 +758,6 @@ typedef struct pglist_data {
>  	__pgdat->node_start_pfn + __pgdat->node_spanned_pages;\
>  })
> =20
> -#include <linux/memory_hotplug.h>
> -
>  extern struct mutex zonelists_mutex;
>  void build_all_zonelists(pg_data_t *pgdat, struct zone *zone);
>  void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzon=
e_idx);
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index 68df9c1..2561863 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -4,6 +4,7 @@
>  #include <linux/spinlock.h>
>  #include <linux/linkage.h>
>  #include <linux/mmzone.h>
> +#include <linux/memory_hotplug.h>
>  #include <linux/list.h>
>  #include <linux/memcontrol.h>
>  #include <linux/sched.h>
> diff --git a/include/linux/topology.h b/include/linux/topology.h
> index d3cf0d6..261a126 100644
> --- a/include/linux/topology.h
> +++ b/include/linux/topology.h
> @@ -30,6 +30,7 @@
>  #include <linux/cpumask.h>
>  #include <linux/bitops.h>
>  #include <linux/mmzone.h>
> +#include <linux/memory_hotplug.h>
>  #include <linux/smp.h>
>  #include <linux/percpu.h>
>  #include <asm/topology.h>
> diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
> index a13291f..545d874 100644
> --- a/include/linux/vmstat.h
> +++ b/include/linux/vmstat.h
> @@ -5,6 +5,7 @@
>  #include <linux/percpu.h>
>  #include <linux/mm.h>
>  #include <linux/mmzone.h>
> +#include <linux/memory_hotplug.h>
>  #include <linux/vm_event_item.h>
>  #include <linux/atomic.h>
> =20
> diff --git a/mm/kmemleak.c b/mm/kmemleak.c
> index 752a705..d7904f3 100644
> --- a/mm/kmemleak.c
> +++ b/mm/kmemleak.c
> @@ -84,6 +84,7 @@
>  #include <linux/percpu.h>
>  #include <linux/hardirq.h>
>  #include <linux/mmzone.h>
> +#include <linux/memory_hotplug.h>
>  #include <linux/slab.h>
>  #include <linux/thread_info.h>
>  #include <linux/err.h>
> diff --git a/mm/mlock.c b/mm/mlock.c
> index f0b9ce5..21854e7 100644
> --- a/mm/mlock.c
> +++ b/mm/mlock.c
> @@ -17,6 +17,7 @@
>  #include <linux/export.h>
>  #include <linux/rmap.h>
>  #include <linux/mmzone.h>
> +#include <linux/memory_hotplug.h>
>  #include <linux/hugetlb.h>
> =20
>  #include "internal.h"
> diff --git a/mm/mmzone.c b/mm/mmzone.c
> index 4596d81..9113e58 100644
> --- a/mm/mmzone.c
> +++ b/mm/mmzone.c
> @@ -8,6 +8,7 @@
>  #include <linux/stddef.h>
>  #include <linux/mm.h>
>  #include <linux/mmzone.h>
> +#include <linux/memory_hotplug.h>
> =20
>  struct pglist_data *first_online_pgdat(void)
>  {
> diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
> index 6d757e3..b6cba5b 100644
> --- a/mm/page_cgroup.c
> +++ b/mm/page_cgroup.c
> @@ -1,5 +1,6 @@
>  #include <linux/mm.h>
>  #include <linux/mmzone.h>
> +#include <linux/memory_hotplug.h>
>  #include <linux/bootmem.h>
>  #include <linux/bit_spinlock.h>
>  #include <linux/page_cgroup.h>
> diff --git a/mm/quicklist.c b/mm/quicklist.c
> index 9422129..ebfcb45 100644
> --- a/mm/quicklist.c
> +++ b/mm/quicklist.c
> @@ -17,6 +17,7 @@
>  #include <linux/gfp.h>
>  #include <linux/mm.h>
>  #include <linux/mmzone.h>
> +#include <linux/memory_hotplug.h>
>  #include <linux/quicklist.h>
> =20
>  DEFINE_PER_CPU(struct quicklist [CONFIG_NR_QUICK], quicklist);
> diff --git a/mm/sparse-vmemmap.c b/mm/sparse-vmemmap.c
> index 1b7e22a..d184aa6 100644
> --- a/mm/sparse-vmemmap.c
> +++ b/mm/sparse-vmemmap.c
> @@ -19,6 +19,7 @@
>   */
>  #include <linux/mm.h>
>  #include <linux/mmzone.h>
> +#include <linux/memory_hotplug.h>
>  #include <linux/bootmem.h>
>  #include <linux/highmem.h>
>  #include <linux/slab.h>
> diff --git a/mm/sparse.c b/mm/sparse.c
> index 6b5fb76..4b80678 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -4,6 +4,7 @@
>  #include <linux/mm.h>
>  #include <linux/slab.h>
>  #include <linux/mmzone.h>
> +#include <linux/memory_hotplug.h>
>  #include <linux/bootmem.h>
>  #include <linux/highmem.h>
>  #include <linux/export.h>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

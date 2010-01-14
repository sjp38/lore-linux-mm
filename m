Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 9A08D6B006A
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 14:17:58 -0500 (EST)
Received: by fxm28 with SMTP id 28so963582fxm.6
        for <linux-mm@kvack.org>; Thu, 14 Jan 2010 11:17:56 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20100114182214.GB4545@ldl.fc.hp.com>
References: <20100113002923.GF2985@ldl.fc.hp.com>
	 <alpine.DEB.2.00.1001140917110.14164@router.home>
	 <20100114182214.GB4545@ldl.fc.hp.com>
Date: Thu, 14 Jan 2010 21:17:55 +0200
Message-ID: <84144f021001141117o6271244cmbe9ba790f9616b2c@mail.gmail.com>
Subject: Re: SLUB ia64 linux-next crash bisected to 756dee75
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Alex Chiang <achiang@hp.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, linux-ia64@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Alex,

On Thu, Jan 14, 2010 at 8:22 PM, Alex Chiang <achiang@hp.com> wrote:
> * Christoph Lameter <cl@linux-foundation.org>:
>> @@ -2086,7 +2086,7 @@ init_kmem_cache_node(struct kmem_cache_n
>> =A0#endif
>> =A0}
>>
>> -static DEFINE_PER_CPU(struct kmem_cache_cpu, kmalloc_percpu[SLUB_PAGE_S=
HIFT]);
>> +static DEFINE_PER_CPU(struct kmem_cache_cpu, kmalloc_percpu[KMALLOC_CAC=
HES]);
>>
>> =A0static inline int alloc_kmem_cache_cpus(struct kmem_cache *s, gfp_t f=
lags)
>> =A0{
>>
>
> Sorry, still crashes.
>
> /ac
>
> INIT: version 2.86 booting
> System Boot Control: Running /etc/init.d/boot
> Mounting procfs at /proc =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 done
> Mounting sysfs at /sys =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 done
> Remounting tmpfs at /dev =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 done
> Initializing /dev =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0done
> Mounting devpts at /dev/pts =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0done
> Starting udevd: udevd version 128 started
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 done
> Loading drivers, configuring devices: input: Power Button as /class/input=
/input2
> ACPI: Power Button [PWRB]
> input: Sleep Button as /class/input/input3
> ACPI: Sleep Button [SLPF]
> sd 0:0:6:0: Attached scsi generic sg0 type 0
> scsi 1:0:2:0: Attached scsi generic sg1 type 5
> sd 2:0:6:0: Attached scsi generic sg2 type 0
> sd 4:0:6:0: Attached scsi generic sg3 type 0
> scsi 5:0:2:0: Attached scsi generic sg4 type 5
> sd 6:0:6:0: Attached scsi generic sg5 type 0
> Unable to handle kernel paging request at virtual address a07ffffe5a7838a=
8
> modprobe[6234]: Oops 8813272891392 [1]
> Modules linked in: sr_mod(+) sg button container(+) usbhid ohci_hcd ehci_=
hcd usbcore fan thermal processor thermal_sys
>
> Pid: 6234, CPU 14, comm: =A0 =A0 =A0 =A0 =A0 =A0 modprobe
> psr : 0000101008526030 ifs : 8000000000000b1d ip =A0: [<a0000001001a9ca0>=
] =A0 =A0Not tainted (2.6.33-rc3-next-20100111-dirty)
> ip is at kmem_cache_open+0x420/0xb20

I don't speak ia-64 so I'm having difficulties figuring out where
exactly it's crashing. Can you use addr2line or similar tool to show
us the exact location of the oops?

> unat: 0000000000000000 pfs : 0000000000000b1d rsc : 0000000000000003
> rnat: 0000000000000000 bsps: 0000000000000000 pr =A0: aa99aaa6aa566659
> ldrs: 0000000000000000 ccv : 0000000000000000 fpsr: 0009804c8a70433f
> csd : 0000000000000000 ssd : 0000000000000000
> b0 =A0: a0000001001a99c0 b6 =A0: a00000010035db20 b7 =A0: a00000010008764=
0
> f6 =A0: 0fff5fffffffff0000000 f7 =A0: 0ffeb8000000000000000
> f8 =A0: 1000f8000000000000000 f9 =A0: 100088000000000000000
> f10 : 10005fffffffff0000000 f11 : 1003e0000000000000080
> r1 =A0: a000000101447ff0 r2 =A0: 0000000000010007 r3 =A0: 000000000008080=
0
> r8 =A0: 0000000000000001 r9 =A0: a0000001010375f8 r10 : 0000000000000000
> r11 : a000000101265d58 r12 : e000078627dffdf0 r13 : e000078627df0000
> r14 : 0000000000000009 r15 : a000000101037668 r16 : 0000000040004000
> r17 : 0000000000000009 r18 : 0000000000000fff r19 : 0000000000000000
> r20 : a000000101037658 r21 : 00000000000003ff r22 : 0000000000003fff
> r23 : 0000000000003fff r24 : 00000000000017ff r25 : 0000000000002fff
> r26 : a000000101037604 r27 : a000000101037600 r28 : a0000001010396e8
> r29 : a000000101037610 r30 : 0000000000000080 r31 : 0000000000000080
>
> Call Trace:
> =A0[<a000000100016970>] show_stack+0x50/0xa0
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sp=3De0000=
78627dff9c0 bsp=3De000078627df14b8
> =A0[<a0000001000171e0>] show_regs+0x820/0x860
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sp=3De0000=
78627dffb90 bsp=3De000078627df1460
> =A0[<a00000010003bc60>] die+0x1a0/0x300
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sp=3De0000=
78627dffb90 bsp=3De000078627df1420
> =A0[<a0000001000688c0>] ia64_do_page_fault+0x8c0/0x9e0
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sp=3De0000=
78627dffb90 bsp=3De000078627df13c8
> =A0[<a00000010000c8a0>] ia64_native_leave_kernel+0x0/0x270
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sp=3De0000=
78627dffc20 bsp=3De000078627df13c8
> =A0[<a0000001001a9ca0>] kmem_cache_open+0x420/0xb20
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sp=3De0000=
78627dffdf0 bsp=3De000078627df12e0
> =A0[<a0000001001aabb0>] dma_kmalloc_cache+0x2d0/0x440
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sp=3De0000=
78627dffdf0 bsp=3De000078627df1290
> =A0[<a0000001001aae30>] get_slab+0x110/0x1a0
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sp=3De0000=
78627dffdf0 bsp=3De000078627df1268
> =A0[<a0000001001ab600>] __kmalloc+0xa0/0x260
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sp=3De0000=
78627dffdf0 bsp=3De000078627df1230
> =A0[<a000000207dd16d0>] sr_probe+0x3b0/0xf20 [sr_mod]
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sp=3De0000=
78627dffdf0 bsp=3De000078627df11c8
> =A0[<a000000100481720>] driver_probe_device+0x180/0x300
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sp=3De0000=
78627dffe20 bsp=3De000078627df1190
> =A0[<a000000100481980>] __driver_attach+0xe0/0x140
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sp=3De0000=
78627dffe20 bsp=3De000078627df1160
> =A0[<a000000100480380>] bus_for_each_dev+0xa0/0x140
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sp=3De0000=
78627dffe20 bsp=3De000078627df1128
> =A0[<a000000100481340>] driver_attach+0x40/0x60
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sp=3De0000=
78627dffe30 bsp=3De000078627df1108
> =A0[<a00000010047f1a0>] bus_add_driver+0x180/0x520
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sp=3De0000=
78627dffe30 bsp=3De000078627df10c0
> =A0[<a000000100482140>] driver_register+0x260/0x400
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sp=3De0000=
78627dffe30 bsp=3De000078627df1078
> =A0[<a0000001004d5f40>] scsi_register_driver+0x40/0x60
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sp=3De0000=
78627dffe30 bsp=3De000078627df1058
> =A0[<a000000207e00070>] init_sr+0x70/0x140 [sr_mod]
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sp=3De0000=
78627dffe30 bsp=3De000078627df1038
> =A0[<a00000010000a960>] do_one_initcall+0xe0/0x360
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sp=3De0000=
78627dffe30 bsp=3De000078627df0ff0
> =A0[<a000000100105ec0>] sys_init_module+0x1e0/0x4c0
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sp=3De0000=
78627dffe30 bsp=3De000078627df0f78
> =A0[<a00000010000c700>] ia64_ret_from_syscall+0x0/0x20
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sp=3De0000=
78627dffe30 bsp=3De000078627df0f78
> =A0[<a000000000010720>] __kernel_syscall_via_break+0x0/0x20
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sp=3De0000=
78627e00000 bsp=3De000078627df0f78
> Disabling lock debugging due to kernel taint
> udevd-event[6232]: '/sbin/modprobe' abnormal exit
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

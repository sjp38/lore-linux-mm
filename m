Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id E038A8E0001
	for <linux-mm@kvack.org>; Wed, 19 Dec 2018 16:15:09 -0500 (EST)
Received: by mail-io1-f72.google.com with SMTP id i11so125247iog.2
        for <linux-mm@kvack.org>; Wed, 19 Dec 2018 13:15:09 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 5sor11843362itu.14.2018.12.19.13.15.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Dec 2018 13:15:08 -0800 (PST)
MIME-Version: 1.0
References: <CABXGCsPu3g8WZXV1RpggLFuL3bgofmXMs1SiPyYnPyEOW7t3Dg@mail.gmail.com>
 <24702c72-cc06-1b54-0ab9-6d2409362c27@amd.com> <CABXGCsMPjKnCb7hpuenL5q3_HJgoGW=VB9FRrBpJsZMtA7LxpA@mail.gmail.com>
 <3ffe451b-1f17-23a5-985b-28d26fbaf7da@amd.com> <09781f6e-5ea3-ccfd-1aa2-79941b089863@amd.com>
 <CABXGCsPE36vkeycDQFhhsSQ0KhVxX4W=6Q5vt=hVzhZo3dZGWA@mail.gmail.com>
 <d40c59b2-fa8f-2687-e650-01a0c63b90a5@amd.com> <C97D2E5E-24AB-4B28-B7D3-BF561E4FF3D6@amd.com>
In-Reply-To: <C97D2E5E-24AB-4B28-B7D3-BF561E4FF3D6@amd.com>
From: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Date: Thu, 20 Dec 2018 02:14:57 +0500
Message-ID: <CABXGCsP9O8p1_hC31faCYkUOnHZp_i=mWuP5_F9v-KPxeOMsdQ@mail.gmail.com>
Subject: Re: After Vega 56/64 GPU hang I unable reboot system
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "StDenis, Tom" <Tom.StDenis@amd.com>
Cc: "Grodzovsky, Andrey" <Andrey.Grodzovsky@amd.com>, "Wentland, Harry" <Harry.Wentland@amd.com>, "Deucher, Alexander" <Alexander.Deucher@amd.com>, "Koenig, Christian" <Christian.Koenig@amd.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>

On Thu, 20 Dec 2018 at 01:56, StDenis, Tom <tom.stdenis@amd.com> wrote:
>
> Sorry missed the gfx ring in the reply.
>
> Um what kernel version?
4.20.0-0.rc6

> Is this the latest umr?
yes, master branch, commit 546c30a71f7b87f97f2a96eab184c3973b014711

> Maybe capture a trace of umr to see what is happening.

Cannot seek to MMIO address: Bad file descriptor
[ERROR]: Could not open ring debugfs file
Program received signal SIGSEGV, Segmentation fault.
umr_pm4_decode_ring (asic=3Dasic@entry=3D0x1c08a50, ringname=3D<optimized
out=3D"">, no_halt=3Dno_halt@entry=3D1) at
/home/mikhail/packaging-work/umr/src/lib/umr_read_pm4_stream.c:333
333 ringdata[0] %=3D ringsize;
(gdb) thread apply all bt full

Thread 1 (Thread 0x7ffff7a22740 (LWP 7844)):
#0  umr_pm4_decode_ring (asic=3Dasic@entry=3D0x1c08a50,
ringname=3D<optimized out=3D"">, no_halt=3Dno_halt@entry=3D1) at
/home/mikhail/packaging-work/umr/src/lib/umr_read_pm4_stream.c:333
        ps =3D <optimized out=3D"">
        ringdata =3D 0x0
        ringsize =3D 8191
#1  0x00000000004b4ac6 in umr_print_waves (asic=3Dasic@entry=3D0x1c08a50)
at /home/mikhail/packaging-work/umr/src/app/print_waves.c:52
        x =3D <optimized out=3D"">
        y =3D <optimized out=3D"">
        shift =3D <optimized out=3D"">
        thread =3D <optimized out=3D"">
        pgm_addr =3D <optimized out=3D"">
        shader_addr =3D <optimized out=3D"">
        wd =3D <optimized out=3D"">
        owd =3D <optimized out=3D"">
        first =3D 1
        col =3D 0
        shader =3D 0x0
        stream =3D <optimized out=3D"">
#2  0x0000000000496952 in main (argc=3D<optimized out=3D"">,
argv=3D<optimized out=3D"">) at
/home/mikhail/packaging-work/umr/src/app/main.c:285
        i =3D 3
        j =3D <optimized out=3D"">
        k =3D <optimized out=3D"">
        l =3D <optimized out=3D"">
        asic =3D 0x1c08a50
        blockname =3D <optimized out=3D"">
        str =3D <optimized out=3D"">
        str2 =3D <optimized out=3D"">
        asicname =3D "\000\000\000\000\004", '\000' <repeats 19=3D""
times=3D"">, "F;\226\000\000\000\000\000\000\000\000\000\004", '\000'
<repeats 19=3D"" times=3D"">, "\a", '\000' <repeats 11=3D"" times=3D"">,
"\004", '\000' <repeats 19=3D"" times=3D"">,
"\027\362\321\000\000\000\000\000\000\000\000\000\004", '\000'
<repeats 31=3D"" times=3D"">, "\004", '\000' <repeats 31=3D"" times=3D"">,
"\004", '\000' <repeats 31=3D"" times=3D"">, "\004", '\000' <repeats 31=3D"=
"
times=3D"">...
        ipname =3D '\000' <repeats 24=3D"" times=3D"">, "F;\226", '\000'
<repeats 29=3D"" times=3D"">, "l-option", '\000' <repeats 24=3D"" times=3D"=
">,
"\006\000\000\000\000\000\000\200", '\000' <repeats 56=3D"" times=3D"">,
"\027\362\321", '\000' <repeats 29=3D"" times=3D"">, "\037", '\000'
<repeats 31=3D"" times=3D"">...
        regname =3D "\000\000\000\000\000 ", '\000' <repeats 18=3D""
times=3D"">, "\017\004", '\000' <repeats 11=3D"" times=3D"">, " ", '\000'
<repeats 18=3D"" times=3D"">, "\220\377\377\377\377\377\377\377", '\000'
<repeats 16=3D"" times=3D"">, "\031", '\000' <repeats 15=3D"" times=3D"">,
"\a\000\000\000\000\000\000\000\037\000\000\000\000\000\000\000\003\000\000=
\000\000\000\000\000\030\220\275\001\000\000\000\000P\000\000\000\000\000\0=
00\000\220\377\377\377\377\377\377\377\000\000\000\000\000\000\000\000\003\=
000\000\000w\000\000\000[\000\000\000\060",
'\000' <repeats 27=3D"" times=3D"">, "n\000\000\000|", '\000' <repeats
19=3D"" times=3D"">...
        req =3D {tv_sec =3D 0, tv_nsec =3D 7310868735956184161}
(gdb)

> It works just fine on my raven1.
>

$ inxi -bM
System:    Host: localhost.localdomain Kernel:
4.20.0-0.rc6.git2.3.fc30.x86_64 x86_64 bits: 64 Desktop: Gnome 3.31.2
           Distro: Fedora release 30 (Rawhide)
Machine:   Type: Desktop Mobo: ASUSTeK model: ROG STRIX X470-I GAMING
v: Rev 1.xx serial: <root required=3D"">
           UEFI: American Megatrends v: 1103 date: 11/16/2018
CPU:       8-Core: AMD Ryzen 7 2700X type: MT MCP speed: 2086 MHz
min/max: 2200/3700 MHz
Graphics:  Device-1: Advanced Micro Devices [AMD/ATI] Vega 10 XL/XT
[Radeon RX Vega 56/64] driver: amdgpu v: kernel
           Display: wayland server: Fedora Project X.org 1.20.3
driver: amdgpu resolution: 3840x2160~60Hz
           OpenGL: renderer: Radeon RX Vega (VEGA10 DRM 3.27.0
4.20.0-0.rc6.git2.3.fc30.x86_64 LLVM 7.0.0) v: 4.5 Mesa 18.3.0
Network:   Device-1: Intel I211 Gigabit Network driver: igb
           Device-2: Realtek RTL8822BE 802.11a/b/g/n/ac WiFi adapter
driver: r8822be
Drives:    Local Storage: total: 11.35 TiB used: 7.54 TiB (66.4%)
Info:      Processes: 435 Uptime: 22m Memory: 31.35 GiB used: 19.69
GiB (62.8%) Shell: bash inxi: 3.0.29


--
Best Regards,
Mike Gavrilov.

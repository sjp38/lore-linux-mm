Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id D23B98E0001
	for <linux-mm@kvack.org>; Sat, 22 Dec 2018 05:28:28 -0500 (EST)
Received: by mail-it1-f199.google.com with SMTP id x3so7853248itb.6
        for <linux-mm@kvack.org>; Sat, 22 Dec 2018 02:28:28 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id t195sor4803398iof.88.2018.12.22.02.28.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 22 Dec 2018 02:28:27 -0800 (PST)
MIME-Version: 1.0
References: <CABXGCsPu3g8WZXV1RpggLFuL3bgofmXMs1SiPyYnPyEOW7t3Dg@mail.gmail.com>
 <CABXGCsMPjKnCb7hpuenL5q3_HJgoGW=VB9FRrBpJsZMtA7LxpA@mail.gmail.com>
 <3ffe451b-1f17-23a5-985b-28d26fbaf7da@amd.com> <09781f6e-5ea3-ccfd-1aa2-79941b089863@amd.com>
 <CABXGCsPE36vkeycDQFhhsSQ0KhVxX4W=6Q5vt=hVzhZo3dZGWA@mail.gmail.com>
 <d40c59b2-fa8f-2687-e650-01a0c63b90a5@amd.com> <C97D2E5E-24AB-4B28-B7D3-BF561E4FF3D6@amd.com>
 <CABXGCsP9O8p1_hC31faCYkUOnHZp_i=mWuP5_F9v-KPxeOMsdQ@mail.gmail.com>
 <CABXGCsMygWFqnkaZbpLEBd9aBkk9=-fRnDMNOnkRfPZaeheoCg@mail.gmail.com>
 <9b87556e-ed4d-6ec0-2f98-a08469b7f35e@amd.com> <CABXGCsMbP8W28NTx_y3viiN=3deiEVkLw0_HBFZa1Qt_8MUVjg@mail.gmail.com>
 <b3aba7f4-b131-64fe-88eb-c1e14e133c51@amd.com> <CABXGCsMJs6X+bK7NS+wPn94H3skcR5a-U9710rSByvn26vg7Gg@mail.gmail.com>
 <4a3060aa-2bc7-9845-0135-ddf27e90740e@amd.com> <fbdd541c-ce31-9fe0-f1ac-bb9c51bb6526@amd.com>
 <96c70496-ce62-b162-187c-ff34ebb84ec2@amd.com> <CABXGCsORwHuOuFT273hTZSkC4tChUC_Mbj8gte2htTR2V0s79Q@mail.gmail.com>
 <5a413fa2-c3a4-d603-2069-fd27b22062cc@amd.com>
In-Reply-To: <5a413fa2-c3a4-d603-2069-fd27b22062cc@amd.com>
From: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Date: Sat, 22 Dec 2018 15:28:18 +0500
Message-ID: <CABXGCsNoqtH0muS6JMHvSPtePam=C+CE=MOqDGhYQCSSieyXGA@mail.gmail.com>
Subject: Re: After Vega 56/64 GPU hang I unable reboot system
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "StDenis, Tom" <Tom.StDenis@amd.com>
Cc: "Grodzovsky, Andrey" <Andrey.Grodzovsky@amd.com>, "Wentland, Harry" <Harry.Wentland@amd.com>, "Deucher, Alexander" <Alexander.Deucher@amd.com>, "Koenig, Christian" <Christian.Koenig@amd.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>

On Thu, 20 Dec 2018 at 21:20, StDenis, Tom <Tom.StDenis@amd.com> wrote:
>
> Sorry I didn't mean to be dismissive.  It's just not a bug in umr though.
>
> On Fedora I can access those files as root just fine:
>
> tom@fx8:~$ sudo bash
> [sudo] password for tom:
> root@fx8:/home/tom# cd /sys/kernel/debug/dri/0
> root@fx8:/sys/kernel/debug/dri/0# xxd -e amdgpu_gca_config
> 00000000: 00000003 00000001 00000004 0000000b  ................
> 00000010: 00000001 00000002 00000004 00000100  ................
> 00000020: 00000020 00000008 00000020 00000100   ....... .......
> 00000030: 00000030 000004c0 00000000 00000003  0...............
> 00000040: 00000000 00000000 00000000 00000000  ................
> 00000050: 00000000 00000000 24000042 00000002  ........B..$....
> 00000060: 00000001 00004100 017f9fcf 0000008e  .....A..........
> 00000070: 00000001 000015dd 000000c6 0000d000  ................
> 00000080: 00001458                             X...
> root@fx8:/sys/kernel/debug/dri/0#
>
> There must be some sort of ACL or something going on here.
>
> Tom
>

Tom, which Fedora version do you tried and with which kernel?
I am tried several kernels from old 4.19-rc2 to fresh 4.20-rc7 and
every time when I tried run `# cat
/sys/kernel/debug/dri/0/amdgpu_gca_config` I got message that
"Operation not permitted".
I try understand difference with our setups. If you use default kernel
it means that kernel options between our setups are same. Difference
only in hardware and mounted file systems.

P.S. I am also tried ask how to manage ACL in debugfs in
platform-driver-x86 mail list, but no one answer.

--
Best Regards,
Mike Gavrilov.

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 846688E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 20:30:58 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id u20so14117828qtk.6
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 17:30:58 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id m2sor16175447qkl.81.2019.01.10.17.30.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 10 Jan 2019 17:30:57 -0800 (PST)
Subject: Re: PROBLEM: syzkaller found / pool corruption-overwrite / page in
 user-area or NULL
References: <t78EEfgpy3uIwPUvqvmuQEYEWKG9avWzjUD3EyR93Qaf_tfx1gqt4XplrqMgdxR1U9SsrVdA7G9XeUZacgUin0n6lBzoxJHVJ9Ko0yzzrxI=@protonmail.ch>
 <1547150339.2814.9.camel@linux.ibm.com> <1547153074.6911.8.camel@lca.pw>
 <4u36JfbOrbu9CXLDErzQKvorP0gc2CzyGe60rBmZsGAGIw6RacZnIfoSsAF0I0TCnVx0OvcqCZFN6ntbgicJ66cWew9cOXRgcuWxSPdL3ko=@protonmail.ch>
 <1547154231.6911.10.camel@lca.pw>
 <hFmbfypBKySVyM6ITf55xUsPWifgqJy6MZ-kFJcYna61S-u2hoClrqr87QTF4F2LhW-K42T2lcCbvsEyGAL0dJTq5CndQBiMT6JnlW4xmdc=@protonmail.ch>
 <1547159604.6911.12.camel@lca.pw>
 <olV6qm38nrHhMMH3bq9cY3h60MaHsW5U9n6xn3_PVP1UkFNJBNbVuS-8P_FdCazGJX6GZX_Qqe2Nj8_hbLJsgto76Xo-gLQ8We-hsc_vRKk=@protonmail.ch>
From: Qian Cai <cai@lca.pw>
Message-ID: <7416c812-f452-9c23-9d0c-37eac0174231@lca.pw>
Date: Thu, 10 Jan 2019 20:30:55 -0500
MIME-Version: 1.0
In-Reply-To: <olV6qm38nrHhMMH3bq9cY3h60MaHsW5U9n6xn3_PVP1UkFNJBNbVuS-8P_FdCazGJX6GZX_Qqe2Nj8_hbLJsgto76Xo-gLQ8We-hsc_vRKk=@protonmail.ch>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Esme <esploit@protonmail.ch>
Cc: James Bottomley <jejb@linux.ibm.com>, "dgilbert@interlog.com" <dgilbert@interlog.com>, "martin.petersen@oracle.com" <martin.petersen@oracle.com>, "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>



On 1/10/19 5:58 PM, Esme wrote:
> The console debug/stacks/info from just now.  The previous config, current kernel from github.
> --
> Esme
> 
> [   75.783231] kasan: CONFIG_KASAN_INLINE enabled
> [   75.785870] kasan: GPF could be caused by NULL-ptr deref or user memory access
> [   75.787695] general protection fault: 0000 [#1] SMP KASAN
> [   75.789084] CPU: 0 PID: 3434 Comm: systemd-journal Not tainted 5.0.0-rc1+ #5
> [   75.790938] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.11.1-1ubuntu1 04/01/2014
> [   75.793150] RIP: 0010:rb_insert_color+0x189/0x1480

What's in that line? Try,

$ ./scripts/faddr2line vmlinux rb_insert_color+0x189/0x1480

What's steps to reproduce this?

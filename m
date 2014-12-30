Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id E2A056B0038
	for <linux-mm@kvack.org>; Mon, 29 Dec 2014 21:10:33 -0500 (EST)
Received: by mail-pd0-f180.google.com with SMTP id fl12so2704129pdb.25
        for <linux-mm@kvack.org>; Mon, 29 Dec 2014 18:10:33 -0800 (PST)
Received: from cdptpa-oedge-vip.email.rr.com (cdptpa-outbound-snat.email.rr.com. [107.14.166.231])
        by mx.google.com with ESMTP id lp6si53800381pab.176.2014.12.29.18.10.31
        for <linux-mm@kvack.org>;
        Mon, 29 Dec 2014 18:10:32 -0800 (PST)
Message-ID: <54A20996.5040105@ubuntu.com>
Date: Mon, 29 Dec 2014 21:10:30 -0500
From: Phillip Susi <psusi@ubuntu.com>
MIME-Version: 1.0
Subject: Re: Memory / swap leak?
References: <54A0A3BB.1070908@ubuntu.com> <alpine.LSU.2.11.1412291026140.2692@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1412291026140.2692@eggly.anvils>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA512

On 12/29/2014 01:49 PM, Hugh Dickins wrote:
> shmem (tmpfs) uses swap, when it won't all fit in memory.  df or du
> on tmpfs mounts in /proc/mounts will report on some of it (and the
> difference between df and du should show if there are unlinked but
> still open files). ipcs -m will report on SysV SHM.
> /sys/kernel/debug/dri/*/i915_gem_objects or similar should report
> on GEM objects.

Thanks, I didn't think about tmpfs.  Turns out the Ubuntu bootchart
package filled the max 2G of the /dev tmpfs.



-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBCgAGBQJUogmVAAoJENRVrw2cjl5RBMsIAKpU5WYeR2w7S0w7j532Imom
G3bwXkFdsDaZ0UUbK6H7uBneqgnMRGGGAjBUtGsjb2TWva4mV+StqkGoqdcVTrgP
NMQ7X/ypgYNa2Zisu4NO8AnyhHkR+ca1JQ0h806puyyHK8EFAoeleUCkzhemCFgT
PfI3pLA/l5x96+jBtEDrgELjVBDwuUGXt8txVLEV3WJfcfRpzR/DfUITyMQTQZjV
O++yeZJnVYWHWRmPjQmGM1bSxmpvovyOXwiVQhiKUd8nb9rvUDnvCSPLfiVrLrUK
cO4cIraHaVJ4KbVjrY7b+zFeDw1NeKakYpO0qW0pR2CPBk39jFSTy/flv+oe/Tk=
=NMKa
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

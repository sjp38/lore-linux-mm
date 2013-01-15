Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id CCE436B0068
	for <linux-mm@kvack.org>; Mon, 14 Jan 2013 21:16:37 -0500 (EST)
Date: Tue, 15 Jan 2013 13:16:23 +1100
From: paul.szabo@sydney.edu.au
Message-Id: <201301150216.r0F2GNYW022199@como.maths.usyd.edu.au>
Subject: Re: [RFC] Reproducible OOM with just a few sleeps
In-Reply-To: <50F4A92F.2070204@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave@linux.vnet.ibm.com
Cc: 695182@bugs.debian.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Dear Dave,

>> ... What is unacceptable is that PAE crashes or freezes with OOM:
>> it should gracefully handle the issue. Noting that (for a machine
>> with 4GB or under) PAE fails where the HIGHMEM4G kernel succeeds ...
>
> You have found a delta, but you're not really making apples-to-apples
> comparisons.  The page tables ...

I understand that the exact sizes of page tables are very important to
developers. To the rest of us, all that matters is that the kernel moves
them to highmem or swap or whatever, that it maybe emits some error
message but that it does not crash or freeze.

> There's probably a bug here.  But, it's incredibly unlikely to be seen
> in practice on anything resembling a modern system. ...

Probably, I found the bug on a very modern and brand-new system, just
trying to copy a few ISO image files and trying to log in a hundred
students. My machine crashed under those very practical and normal
circumstances. The demos with dd and sleep were just that: easily
reproducible demos.

> ... easily worked around by upgrading to a 64-bit kernel ...

Do you mean that PAE should never be used, but to use amd64 instead?

> ... Raising the vm.min_free_kbytes sysctl (to perhaps 10x of
> its current value on your system) is likely to help the hangs too,
> although it will further "consume" lowmem.

I have tried that, it did not work. As you say, it is backward.

> ... for a bug with ... so many reasonable workarounds ...

Only one workaround was proposed: use amd64.

PAE is buggy and useless, should be deprecated and removed.

Cheers, Paul

Paul Szabo   psz@maths.usyd.edu.au   http://www.maths.usyd.edu.au/u/psz/
School of Mathematics and Statistics   University of Sydney    Australia

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

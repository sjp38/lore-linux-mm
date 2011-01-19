Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 93C148D003A
	for <linux-mm@kvack.org>; Wed, 19 Jan 2011 14:56:25 -0500 (EST)
Date: Wed, 19 Jan 2011 20:55:46 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: 2.6.38-rc1 problems with khugepaged
Message-ID: <20110119195546.GJ9506@random.random>
References: <web-442414153@zbackend1.aha.ru>
 <20110119155954.GA2272@kryptos.osrc.amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110119155954.GA2272@kryptos.osrc.amd.com>
Sender: owner-linux-mm@kvack.org
To: Borislav Petkov <bp@amd64.org>
Cc: werner <w.landgraf@ru.ru>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Jan 19, 2011 at 04:59:54PM +0100, Borislav Petkov wrote:
> Adding some more parties to CC.

Thanks for adding me to CC.

Werner, could you send me the vmlinux (or bzImage) of the exact kernel
that crashed (don't rebuild), otherwise I don't know where it
crashed...

Crash on booting sounds like it's very reproducible, that's great so
we fix it immediately (maybe it's related to highpte or some other
.config difference that wasn't exercised). Probably 32bit THP got 0.1%
of the testing that 64bit version had... (if I don't get a
vmlinux/bzImage of the kernel that crashed soon, I'll try to reproduce
on a VM with the .config attached, I've no host with 32bit userland
anymore..).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

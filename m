Received: from adore.lightlink.com (kimoto@adore.lightlink.com [205.232.34.20])
	by kvack.org (8.8.7/8.8.7) with ESMTP id QAA20172
	for <linux-mm@kvack.org>; Fri, 19 Jun 1998 16:15:47 -0400
From: Paul Kimoto <kimoto@lightlink.com>
Message-ID: <19980619161417.40049@adore.lightlink.com>
Date: Fri, 19 Jun 1998 16:14:17 -0400
Subject: Re: update re: fork() failures [in 2.1.103]
References: <19980619110148.53909@adore.lightlink.com> <Pine.LNX.3.96.980619185625.6318F-100000@mirkwood.dummy.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.3.96.980619185625.6318F-100000@mirkwood.dummy.home>; from Rik van Riel on Fri, Jun 19, 1998 at 06:59:56PM +0200
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: Linux MM <linux-mm@kvack.org>, woltman@magicnet.net
List-ID: <linux-mm.kvack.org>

On Fri, Jun 19, 1998 at 06:59:56PM +0200, Rik van Riel wrote:
>> %CPU %MEM  SIZE   RSS
>> 95.7  1.6  9364   520 mprime        15.4.2 (internet Mersenne prime search)

> Shouldn't be much of a problem... But 'eh, does the
> Mersenne program regularly do memory I/O?
> It could be that it loads large chunks of memory and
> frees small portions from the middle of it. The Linux
> MM system could have a problem with that...

> The reason I picked this process, is that it's RSS is
> only one 18th of it's total size, which is somewhat
> weird for a 'normal' Unix process.

I *think* that it allocates a huge amount of memory,
then uses only a small portion of it.

The above shows an inconsistency between "ps" and "top":
  according to "ps",      SIZE=9364, RSS=404;
  but according to "top", SIZE= 500, RSS=404, SWAP=96.

"grep '^Vm' /proc/<pid>/status" says
> VmSize:     9364 kB
> VmLck:         0 kB
> VmRSS:       464 kB
> VmData:     8400 kB
> VmStk:        12 kB
> VmExe:        72 kB
> VmLib:       580 kB

	-Paul <kimoto@lightlink.com>

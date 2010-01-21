Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 696276B006A
	for <linux-mm@kvack.org>; Wed, 20 Jan 2010 20:32:16 -0500 (EST)
Date: Thu, 21 Jan 2010 01:32:05 +0000
From: Jamie Lokier <jamie@shareable.org>
Subject: Re: cache alias in mmap + write
Message-ID: <20100121013205.GA29808@shareable.org>
References: <20100120174630.4071.A69D9226@jp.fujitsu.com> <20100120095242.GA5672@desktop> <20100121094733.3778.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100121094733.3778.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: anfei <anfei.zhou@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux@arm.linux.org.uk
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro wrote:
>  2. Add some commnet. almost developer only have x86 machine. so, arm
>     specific trick need additional explicit explanation. otherwise anybody
>     might break this code in the future.

That's Documentation/cachetlb.txt.

What's being discussed here is not ARM-specific, although it appears
maintainers of different architecture (ARM and MIPS for a start) may
have different ideas about what they are guaranteeing to userspace.
It sounds like MIPS expects userspace to use msync() sometimes (even
though Linux msync(MS_INVALIDATE) is quite broken), and ARM expects to
to keep mappings coherent automatically (which is sometimes slower
than necessary, but usually very helpful).

>  3. Resend the patch. original mail isn't good patch format. please
>  consider to reduce akpm suffer.

This type of change in generic code would need review from a number of
architecture maintainers, I'd expect.

-- Jamie

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

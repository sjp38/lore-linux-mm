Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id RAA06709
	for <linux-mm@kvack.org>; Sun, 15 Dec 2002 17:03:39 -0800 (PST)
Message-ID: <3DFD266A.422CB70C@digeo.com>
Date: Sun, 15 Dec 2002 17:03:38 -0800
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: freemaps
References: <3DFBF26B.47C04A6@digeo.com> <Pine.LNX.4.44.0212150926130.1831-100000@localhost.localdomain> <3DFC455E.1FD92CBC@digeo.com> <20021216005103.GF2690@holomorphy.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Ingo Molnar <mingo@elte.hu>, "Frederic Rossi (LMC)" <Frederic.Rossi@ericsson.ca>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:
> 
> On Sun, Dec 15, 2002 at 01:03:26AM -0800, Andrew Morton wrote:
> > - How does it play with non-linear mappings?
> 
> It doesn't care; they're just vma's parked on a virtual address range
> like the rest of them.
> 

But the searching needs are different.  If someone has a nonlinear mmap
of the 0-1M region of a file and then requests an mmap of the 4-5M region,
that can just be tacked onto the 0-1M mapping's vma (can't it?).
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

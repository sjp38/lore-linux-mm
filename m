Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id EAA25413
	for <linux-mm@kvack.org>; Fri, 14 Mar 2003 04:15:05 -0800 (PST)
Date: Fri, 14 Mar 2003 04:14:56 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: 2.5.64-mm6
Message-Id: <20030314041456.7ee6b710.akpm@digeo.com>
In-Reply-To: <3E71C47F.1050205@aitel.hist.no>
References: <20030313032615.7ca491d6.akpm@digeo.com>
	<3E71C47F.1050205@aitel.hist.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Helge Hafting <helgehaf@aitel.hist.no>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Helge Hafting <helgehaf@aitel.hist.no> wrote:
>
> Andrew Morton wrote:
> >   This might cause weird thing to happen, especially on small-memory machines.
> 
> Weird things happened.
> mm1 (and mm2 on smp) have been running very fine for me. So I decided to 
> try mm6 on UP.  The machine have 512M, and uses soft raid-1 on /  The
> rest is plain ide disk partitions, all using ext2.
> 
> It booted fine.
> I fired up openoffice, a 2x-3x speedup ought to be noticeable.
> It didn't start, but got stuck with the annoying on-top-of-everything 
> splash screen showing.  ps aux showed lpd in D state - perhaps
> oo queries lpd.  I also tried mozilla, and it got stuck in D state too.
> Openoffice was only in sleep so I killed it.  Mozilla was unkillable
> as expected from the D state.

The elevator bug.  I'll make deadline the deefault until we get this sorted.
Booting with "elevator=deadline" should be OK.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>

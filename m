Message-ID: <3B75B2A8.2E8A42EE@zip.com.au>
Date: Sat, 11 Aug 2001 15:33:12 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: vmstats patch against 2.4.8pre7 and new userlevel hack
References: <01081022333100.00293@starship> <Pine.LNX.4.21.0108111349500.17282-100000@freak.distro.conectiva>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: Daniel Phillips <phillips@bonn-fries.net>, lkml <linux-kernel@vger.kernel.org>, Zach Brown <zab@osdlab.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Marcelo Tosatti wrote:
> 
> > Problem: none of the statistics show up in proc until the first time the
> > kernel hits them.  The /proc/stats entry isn't even there until the kernel
> > hits the first statistic.  This isn't user-friendly.
> 
> Right. This has to be fixed.
> 

Does it?  The userspace tool can just assume the value is zero
if it isn't available.

If we want unencountered counters to appear in the summary
we'd have to declare them, which means two lines of code
rather than one :)
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

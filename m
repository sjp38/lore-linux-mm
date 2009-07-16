Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id CAFD56B004D
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 00:26:59 -0400 (EDT)
Date: Wed, 15 Jul 2009 21:26:57 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -mm] throttle direct reclaim when too many pages are
 isolated already (v3)
Message-Id: <20090715212657.aa85089a.akpm@linux-foundation.org>
In-Reply-To: <4A5EA7E1.7030403@redhat.com>
References: <20090715223854.7548740a@bree.surriel.com>
	<20090715194820.237a4d77.akpm@linux-foundation.org>
	<4A5E9A33.3030704@redhat.com>
	<20090715202114.789d36f7.akpm@linux-foundation.org>
	<4A5E9E4E.5000308@redhat.com>
	<20090715203854.336de2d5.akpm@linux-foundation.org>
	<20090715235318.6d2f5247@bree.surriel.com>
	<20090715210253.bc137b2d.akpm@linux-foundation.org>
	<4A5EA7E1.7030403@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

On Thu, 16 Jul 2009 00:09:05 -0400 Rik van Riel <riel@redhat.com> wrote:

> > If we were to step back and approach this in a broader fashion, perhaps
> > we would find some commonality with the existing TIF_MEMDIE handling,
> > dunno.
> 
> Good point - what is it that makes TIF_MEMDIE special
> wrt. other fatal signals, anyway?
> 
> I wonder if we should not simply "help along" any task
> with fatal signals pending, anywhere in the VM (and maybe
> other places in the kernel, too).
> 
> The faster we get rid of a killed process, the sooner its
> resources become available to the other processes.

Spose so.

Are their any known (or makeable uppable) situations in which such a
change would be beneficial?  Maybe if the system is in a hopeless
swapstorm and someone is killing processes in an attempt to get control
back.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

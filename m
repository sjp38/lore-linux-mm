Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id DAA116B004D
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 08:15:32 -0500 (EST)
Date: Tue, 17 Nov 2009 13:15:28 +0000
From: Alasdair G Kergon <agk@redhat.com>
Subject: Re: [PATCH 1/7] dm: use __GFP_HIGH instead PF_MEMALLOC
Message-ID: <20091117131527.GB6644@agk-dp.fab.redhat.com>
References: <20091117161551.3DD4.A69D9226@jp.fujitsu.com> <20091117161616.3DD7.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091117161616.3DD7.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, dm-devel@redhat.com
List-ID: <linux-mm.kvack.org>

On Tue, Nov 17, 2009 at 04:17:07PM +0900, KOSAKI Motohiro wrote:
> Non MM subsystem must not use PF_MEMALLOC. Memory reclaim need few
> memory, anyone must not prevent it. Otherwise the system cause
> mysterious hang-up and/or OOM Killer invokation.
 
This code is also on the critical path, for example, if you are swapping
onto a dm device.  (There are ways we could reduce its use further as
not every dm ioctl needs to be on the critical path and the buffer size
could be limited for the ioctls that do.)

But what situations have been causing you trouble?  The OOM killer must
generally avoid killing userspace processes that suspend & resume dm
devices, and there are tight restrictions on what those processes
can do safely between suspending and resuming.

Alasdair

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

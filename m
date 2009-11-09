Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1DD1F6B004D
	for <linux-mm@kvack.org>; Mon,  9 Nov 2009 05:11:35 -0500 (EST)
Date: Mon, 9 Nov 2009 10:11:28 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 2/3] page allocator: Do not allow interrupts to use
	ALLOC_HARDER
Message-ID: <20091109101128.GB6657@csn.ul.ie>
References: <alpine.DEB.2.00.0910271411530.9183@chino.kir.corp.google.com> <20091031184054.GB1475@ucw.cz> <alpine.DEB.2.00.0910311248490.13829@chino.kir.corp.google.com> <20091031201158.GB29536@elf.ucw.cz> <4AECCF6A.4020206@redhat.com> <alpine.DEB.1.10.0911021139100.24535@V090114053VZO-1> <alpine.DEB.2.00.0911021249470.22525@chino.kir.corp.google.com> <alpine.DEB.1.10.0911031208150.21943@V090114053VZO-1> <alpine.DEB.2.00.0911031739380.1187@chino.kir.corp.google.com> <20091104090140.GA14694@elf.ucw.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20091104090140.GA14694@elf.ucw.cz>
Sender: owner-linux-mm@kvack.org
To: Pavel Machek <pavel@ucw.cz>
Cc: David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, stable@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Stephan von Krawczynski <skraw@ithnet.com>, kernel-testers@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Nov 04, 2009 at 10:01:40AM +0100, Pavel Machek wrote:
> 
> > I hope we can move this to another thread if people would like to remove 
> > this exemption completely instead of talking about this trivial fix, which 
> > I doubt there's any objection to.
> 
> I'm arguing that this "trivial fix" is wrong, and that you should just
> remove those two lines.
> 
> If going into reserves from interrupts hurts, doing that from task
> context will hurt, too. "realtime" task should not be normally allowed
> to "hurt" the system like that.
> 									Pavel

As David points out, it has been the behaviour of the system for 4 years
and removing it should be made as a separate decision and not in the
guise of a fix. In the particular case causing concern, there are a lot
more allocations from interrupt due to network receive than there are
from the activities of tasks with a high priority.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

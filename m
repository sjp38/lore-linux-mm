Date: Mon, 30 Jul 2007 18:06:42 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [rfc] [patch] mm: zone_reclaim fix for pseudo file systems
Message-Id: <20070730180642.0a25eed8.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0707301725280.25686@schroedinger.engr.sgi.com>
References: <20070727232753.GA10311@localdomain>
	<20070730132314.f6c8b4e1.akpm@linux-foundation.org>
	<20070731000138.GA32468@localdomain>
	<20070730172007.ddf7bdee.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0707301725280.25686@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Ravikiran G Thirumalai <kiran@scalex86.org>, linux-mm@kvack.org, Christoph Lameter <clameter@cthulhu.engr.sgi.com>, shai@scalex86.org
List-ID: <linux-mm.kvack.org>

On Mon, 30 Jul 2007 17:27:41 -0700 (PDT) Christoph Lameter <clameter@sgi.com> wrote:

> On Mon, 30 Jul 2007, Andrew Morton wrote:
> 
> > The problem is that __zone_reclaim() doesn't use all_unreclaimable at all.
> > You'll note that all the other callers of shrink_zone() do take avoiding
> > action if the zone is in all_unreclaimable state, but __zone_reclaim() forgot
> > to.
> 
> zone reclaim only runs if there are unmapped file backed pages that can be 
> reclaimed. If the pages are all unreclaimable then they are all mapped and 
> global reclaim begins to run. The problem is with global reclaim as far as 
> I know.

I don't understand how you conclude that.

- Kiran saw CPU meltdown when "one of the processes got into zone reclaim".

- all_unreclaimable is there specifically to prevent CPU meltdown

- zone_reclaim doesn't utilise all_unreclaimable.

so..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

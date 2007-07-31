Date: Mon, 30 Jul 2007 18:56:47 -0700
From: Ravikiran G Thirumalai <kiran@scalex86.org>
Subject: Re: [rfc] [patch] mm: zone_reclaim fix for pseudo file systems
Message-ID: <20070731015647.GC32468@localdomain>
References: <20070727232753.GA10311@localdomain> <20070730132314.f6c8b4e1.akpm@linux-foundation.org> <20070731000138.GA32468@localdomain> <20070730172007.ddf7bdee.akpm@linux-foundation.org> <Pine.LNX.4.64.0707301725280.25686@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0707301725280.25686@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Christoph Lameter <clameter@cthulhu.engr.sgi.com>, shai@scalex86.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 30, 2007 at 05:27:41PM -0700, Christoph Lameter wrote:
>On Mon, 30 Jul 2007, Andrew Morton wrote:
>
>> The problem is that __zone_reclaim() doesn't use all_unreclaimable at all.
>> You'll note that all the other callers of shrink_zone() do take avoiding
>> action if the zone is in all_unreclaimable state, but __zone_reclaim() forgot
>> to.
>
>zone reclaim only runs if there are unmapped file backed pages that can be 
>reclaimed. 

Yes, and in this case, without the patch, VM considers RAMFS pages to be
file backed, thus being fooled into entering reclaim.  The process entering
into reclaim in our tests gets in through zone_reclaim.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

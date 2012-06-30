Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id ECB046B009F
	for <linux-mm@kvack.org>; Sat, 30 Jun 2012 07:41:07 -0400 (EDT)
Date: Sat, 30 Jun 2012 13:40:57 +0200
From: Petr Holasek <pholasek@redhat.com>
Subject: Re: [PATCH v2] KSM: numa awareness sysfs knob
Message-ID: <20120630114053.GA3036@stainedmachine.redhat.com>
References: <1340970592-25001-1-git-send-email-pholasek@redhat.com>
 <20120629160510.GA10082@cmpxchg.org>
 <20120629163033.GA11327@stainedmachine.redhat.com>
 <20120629164706.GA7831@cmpxchg.org>
 <alpine.DEB.2.00.1206291526180.15200@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1206291526180.15200@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Chris Wright <chrisw@sous-sol.org>, Izik Eidus <izik.eidus@ravellosystems.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Anton Arapov <anton@redhat.com>

On Fri, 29 Jun 2012, David Rientjes wrote:
> On Fri, 29 Jun 2012, Johannes Weiner wrote:
> 
> > > I started with exactly same idea as you described above in the first
> > > RFC, link: https://lkml.org/lkml/2011/11/30/91
> > > But this approach turned out to be more complicated than it looked
> > > (see two last emails in thread) and complexity of solution would rise
> > > a lot.
> > 
> > Oh, I should have checked the archives given that it's v2.  I expected
> > it to get complex but didn't put enough thought into it to see /that/
> > amount of complexity.  Sorry.
> > 
> > Carry on, then :-)
> > 
> 
> I don't think it's an unfair amount of complexity to ask for, and I don't 
> see the problem with ksm merging two pages that have a distance under the 
> configured threshold and leaving the third page unmerged; by configuring 
> the threshold (which should be a char, not an int) the admin has specified 
> the locality that is necessary for optimal performance so has knowingly 
> restricted ksm in that way.
> 
> I'd rename it to ksm_merge_distance, which is more similar to 
> reclaim_distance, and return to the first version of this patch.

The problem of the first patch/RFC was that merging algorithm was unstable
and could merge pages with distance higher than was set up (described by 
Nai Xia in RFC thread [1]). Sure, this instability could be solved, but for
ksm pages shared by many other pages on different nodes we would have to still
recalculate which page is "in the middle" and in case of change migrate it 
between nodes every time when ksmd reach new shareable page or when some 
sharing page is removed.

But please correct me if I understand you wrong.

[1] https://lkml.org/lkml/2011/12/1/167

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

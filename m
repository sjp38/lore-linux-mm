Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 7B70A6B0073
	for <linux-mm@kvack.org>; Thu, 12 Jul 2012 11:40:20 -0400 (EDT)
Received: by ggm4 with SMTP id 4so3059305ggm.14
        for <linux-mm@kvack.org>; Thu, 12 Jul 2012 08:40:19 -0700 (PDT)
Date: Thu, 12 Jul 2012 17:40:11 +0200
From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: Re: Fork bomb limitation in memcg WAS: Re: [PATCH 00/11] kmem
 controller for memcg: stripped down version
Message-ID: <20120712154008.GB2185@somewhere.redhat.com>
References: <1340633728-12785-1-git-send-email-glommer@parallels.com>
 <20120625162745.eabe4f03.akpm@linux-foundation.org>
 <4FE9621D.2050002@parallels.com>
 <20120626145539.eeeab909.akpm@linux-foundation.org>
 <4FEAD260.4000603@parallels.com>
 <alpine.DEB.2.00.1206271233080.22162@chino.kir.corp.google.com>
 <4FEC1D63.6000903@parallels.com>
 <20120628152540.cc13a735.akpm@linux-foundation.org>
 <4FF2D9BF.20800@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4FF2D9BF.20800@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Pekka Enberg <penberg@kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, devel@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, Tejun Heo <tj@kernel.org>, Rik van Riel <riel@redhat.com>, Daniel Lezcano <daniel.lezcano@linaro.org>, Kay Sievers <kay.sievers@vrfy.org>, Lennart Poettering <lennart@poettering.net>, "Kirill A. Shutemov" <kirill@shutemov.name>, Kir Kolyshkin <kir@parallels.com>

On Tue, Jul 03, 2012 at 03:38:39PM +0400, Glauber Costa wrote:
> On 06/29/2012 02:25 AM, Andrew Morton wrote:
> > On Thu, 28 Jun 2012 13:01:23 +0400
> > Glauber Costa <glommer@parallels.com> wrote:
> > 
> >>
> >> ...
> >>
> > 
> > OK, that all sounds convincing ;) Please summarise and capture this
> > discussion in the [patch 0/n] changelog so we (or others) don't have to
> > go through this all again.  And let's remember this in the next
> > patchset!
> 
> Thanks, will surely do.
> 
> >> Last, but not least, note that it is totally within my interests to
> >> merge the slab tracking as fast as we can. it'll be a matter of going
> >> back to it, and agreeing in the final form.
> > 
> > Yes, I'd very much like to have the whole slab implementation in a
> > reasonably mature state before proceeding too far with this base
> > patchset.
> 
> Does that means that you want to merge them together? I am more than
> happy to post the slab part again ontop of that to have people reviewing it.
> 
> But if possible, I believe that merging this part first would help us to
> split up testing in a beneficial way, in the sense that if it breaks, we
> know at least in which part it is. Not to mention, of course, that
> reviewers will have an easier time reviewing it as two pieces.

Definetly yeah. This makes the review easier for this tricky chunk.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

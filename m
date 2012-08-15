Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 170FA6B005D
	for <linux-mm@kvack.org>; Wed, 15 Aug 2012 07:12:31 -0400 (EDT)
Message-ID: <1345029143.2976.41.camel@dabdike.int.hansenpartnership.com>
Subject: Re: [PATCH v2 04/11] kmem accounting basic infrastructure
From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Wed, 15 Aug 2012 12:12:23 +0100
In-Reply-To: <502B6D03.1080804@parallels.com>
References: <1344517279-30646-1-git-send-email-glommer@parallels.com>
	 <1344517279-30646-5-git-send-email-glommer@parallels.com>
	 <20120814162144.GC6905@dhcp22.suse.cz> <502B6D03.1080804@parallels.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, kamezawa.hiroyu@jp.fujitsu.com, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>

On Wed, 2012-08-15 at 13:33 +0400, Glauber Costa wrote:
> > This can
> > be quite confusing.  I am still not sure whether we should mix the two
> > things together. If somebody wants to limit the kernel memory he has to
> > touch the other limit anyway.  Do you have a strong reason to mix the
> > user and kernel counters?
> 
> This is funny, because the first opposition I found to this work was
> "Why would anyone want to limit it separately?" =p
> 
> It seems that a quite common use case is to have a container with a
> unified view of "memory" that it can use the way he likes, be it with
> kernel memory, or user memory. I believe those people would be happy to
> just silently account kernel memory to user memory, or at the most have
> a switch to enable it.
> 
> What gets clear from this back and forth, is that there are people
> interested in both use cases.

Haven't we already had this discussion during the Prague get together?
We discussed the use cases and finally agreed to separate accounting for
k and then k+u mem because that satisfies both the Google and Parallels
cases.  No-one was overjoyed by k and k+u but no-one had a better
suggestion ... is there a better way of doing this that everyone can
agree to?

We do need to get this nailed down because it's the foundation of the
patch series.

James


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

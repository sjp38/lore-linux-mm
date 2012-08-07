Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id EED2A6B004D
	for <linux-mm@kvack.org>; Tue,  7 Aug 2012 09:59:43 -0400 (EDT)
Message-ID: <50211F3D.2000008@parallels.com>
Date: Tue, 7 Aug 2012 17:59:25 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: Fork bomb limitation in memcg WAS: Re: [PATCH 00/11] kmem controller
 for memcg: stripped down version
References: <1340633728-12785-1-git-send-email-glommer@parallels.com> <20120625162745.eabe4f03.akpm@linux-foundation.org> <4FE9621D.2050002@parallels.com> <20120626145539.eeeab909.akpm@linux-foundation.org> <4FEAD260.4000603@parallels.com> <alpine.DEB.2.00.1206271233080.22162@chino.kir.corp.google.com> <4FEC1D63.6000903@parallels.com> <20120628152540.cc13a735.akpm@linux-foundation.org>
In-Reply-To: <20120628152540.cc13a735.akpm@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Frederic Weisbecker <fweisbec@gmail.com>, Pekka Enberg <penberg@kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, devel@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, Tejun Heo <tj@kernel.org>, Rik van Riel <riel@redhat.com>, Daniel Lezcano <daniel.lezcano@linaro.org>, Kay Sievers <kay.sievers@vrfy.org>, Lennart Poettering <lennart@poettering.net>, "Kirill A. Shutemov" <kirill@shutemov.name>, Kir Kolyshkin <kir@parallels.com>

On 06/29/2012 02:25 AM, Andrew Morton wrote:
> On Thu, 28 Jun 2012 13:01:23 +0400
> Glauber Costa <glommer@parallels.com> wrote:
> 
>>
>> ...
>>
> 
> OK, that all sounds convincing ;) Please summarise and capture this
> discussion in the [patch 0/n] changelog so we (or others) don't have to
> go through this all again.  And let's remember this in the next
> patchset!
> 
>> Last, but not least, note that it is totally within my interests to
>> merge the slab tracking as fast as we can. it'll be a matter of going
>> back to it, and agreeing in the final form.
> 
> Yes, I'd very much like to have the whole slab implementation in a
> reasonably mature state before proceeding too far with this base
> patchset.
> 
So, that was posted separately as well.

Although there is a thing to fix here and there - all of them I am
working on already - I believe that to be mature enough.

Do you have any comments on that? Would you be willing to take this
first part (modified with the comments on this thread itself) and let it
start sitting in the tree?

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

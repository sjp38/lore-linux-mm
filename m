Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 7F7BE6B0089
	for <linux-mm@kvack.org>; Wed,  7 Aug 2013 05:21:25 -0400 (EDT)
Date: Wed, 7 Aug 2013 18:21:28 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 0/2] hugepage: optimize page fault path locking
Message-ID: <20130807092128.GE32449@lge.com>
References: <1374848845-1429-1-git-send-email-davidlohr.bueso@hp.com>
 <20130729061820.GA4784@lge.com>
 <1375834084.2134.44.camel@buesod1.americas.hpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1375834084.2134.44.camel@buesod1.americas.hpqcorp.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: Davidlohr Bueso <davidlohr.bueso@hp.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "AneeshKumarK.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, David Gibson <david@gibson.dropbear.id.au>, Eric B Munson <emunson@mgebm.net>, Anton Blanchard <anton@samba.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Aug 06, 2013 at 05:08:04PM -0700, Davidlohr Bueso wrote:
> On Mon, 2013-07-29 at 15:18 +0900, Joonsoo Kim wrote:
> > On Fri, Jul 26, 2013 at 07:27:23AM -0700, Davidlohr Bueso wrote:
> > > This patchset attempts to reduce the amount of contention we impose
> > > on the hugetlb_instantiation_mutex by replacing the global mutex with
> > > a table of mutexes, selected based on a hash. The original discussion can 
> > > be found here: http://lkml.org/lkml/2013/7/12/428
> > 
> > Hello, Davidlohr.
> > 
> > I recently sent a patchset which remove the hugetlb_instantiation_mutex
> > entirely ('mm, hugetlb: remove a hugetlb_instantiation_mutex').
> > This patchset can be found here: https://lkml.org/lkml/2013/7/29/54
> > 
> > If possible, could you review it and test it whether your problem is
> > disappered with it or not?
> 
> This patchset applies on top of https://lkml.org/lkml/2013/7/22/96
> "[PATCH v2 00/10] mm, hugetlb: clean-up and possible bug fix", right?
> 
> AFAIK those changes are the ones Andrew picked up a few weeks ago and
> are now in linux-next, right? I was able to apply those just fine, but
> couldn't apply your 'remove a hugetlb_instantiation_mutex series' (IIRC
> pach 1/18 failed). I guess you'll send out a v2 anyway so I'll wait
> until then.
> 
> In any case I'm not seeing an actual performance issue with the
> hugetlb_instantiation_mutex, all I noticed was that under large DB
> workloads that make use of hugepages, such as Oracle, this lock becomes
> quite hot during the first few minutes of startup, which makes sense in
> the fault path it is contended. So I'll try out your patches, but, in
> this particular case, I just cannot compare with the lock vs without the
> lock situations.

Okay. I just want to know that lock contention is reduced by my patches
in the first few minutes of startup. I will send v2 soon.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

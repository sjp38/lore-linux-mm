Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id BCC9F6B002C
	for <linux-mm@kvack.org>; Mon,  5 Mar 2012 22:07:21 -0500 (EST)
Received: from /spool/local
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dwg@au1.ibm.com>;
	Tue, 6 Mar 2012 03:04:32 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q2636LOZ729156
	for <linux-mm@kvack.org>; Tue, 6 Mar 2012 14:06:24 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q2636KFV025104
	for <linux-mm@kvack.org>; Tue, 6 Mar 2012 14:06:21 +1100
Date: Tue, 6 Mar 2012 13:38:09 +1100
From: David Gibson <dwg@au1.ibm.com>
Subject: Re: [PATCH -V2 0/9] memcg: add HugeTLB resource tracking
Message-ID: <20120306023809.GF12818@truffala.fritz.box>
References: <1330593380-1361-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <20120301144029.545a5589.akpm@linux-foundation.org>
 <20120302032853.GB2728@truffala.fritz.box>
 <87fwdodyr0.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87fwdodyr0.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, aarcange@redhat.com, mhocko@suse.cz, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

On Sun, Mar 04, 2012 at 11:39:23PM +0530, Aneesh Kumar K.V wrote:
> On Fri, 2 Mar 2012 14:28:53 +1100, David Gibson <dwg@au1.ibm.com> wrote:
> > On Thu, Mar 01, 2012 at 02:40:29PM -0800, Andrew Morton wrote:
> > > On Thu,  1 Mar 2012 14:46:11 +0530
> > > "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:
> > > 
> > > > This patchset implements a memory controller extension to control
> > > > HugeTLB allocations. It is similar to the existing hugetlb quota
> > > > support in that, the limit is enforced at mmap(2) time and not at
> > > > fault time. HugeTLB's quota mechanism limits the number of huge pages
> > > > that can allocated per superblock.
> > > > 
> > > > For shared mappings we track the regions mapped by a task along with the
> > > > memcg. We keep the memory controller charged even after the task
> > > > that did mmap(2) exits. Uncharge happens during truncate. For Private
> > > > mappings we charge and uncharge from the current task cgroup.
> > > 
> > > I haven't begin to get my head around this yet, but I'd like to draw
> > > your attention to https://lkml.org/lkml/2012/2/15/548.  That fix has
> > > been hanging around for a while, but I haven't done anything with it
> > > yet because I don't like its additional blurring of the separation
> > > between hugetlb core code and hugetlbfs.  I want to find time to sit
> > > down and see if the fix can be better architected but haven't got
> > > around to that yet.
> > 
> > So.. that version of the fix I specifically rebuilt to address your
> > concerns about that blurring - in fact I think it reduces the current
> > layer blurring.  I haven't had any reply - what problems do see it as
> > still having?
> 
> https://lkml.org/lkml/2012/2/16/179 ?

Ah.  Missed that reply somehow.  Odd.  Replied now and I'll respin
accordingly.

> That is a serious issue isn't it ?

Yes, it is.  And it's been around for a long, long time.

-- 
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

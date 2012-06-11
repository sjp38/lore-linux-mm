Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 9DD256B0152
	for <linux-mm@kvack.org>; Mon, 11 Jun 2012 11:35:42 -0400 (EDT)
Received: from /spool/local
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 11 Jun 2012 15:26:34 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5BFSJUR8323536
	for <linux-mm@kvack.org>; Tue, 12 Jun 2012 01:28:19 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5BFZZ80003434
	for <linux-mm@kvack.org>; Tue, 12 Jun 2012 01:35:36 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH -V8 11/16] hugetlb/cgroup: Add charge/uncharge routines for hugetlb cgroup
In-Reply-To: <20120611125952.GM12402@tiehlicka.suse.cz>
References: <1339232401-14392-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1339232401-14392-12-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20120611083810.GC12402@tiehlicka.suse.cz> <87liju5h9u.fsf@skywalker.in.ibm.com> <20120611125952.GM12402@tiehlicka.suse.cz>
Date: Mon, 11 Jun 2012 21:05:30 +0530
Message-ID: <878vftvp31.fsf@skywalker.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, rientjes@google.com, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

Michal Hocko <mhocko@suse.cz> writes:

> On Mon 11-06-12 14:58:45, Aneesh Kumar K.V wrote:
>> Michal Hocko <mhocko@suse.cz> writes:
>> 
>> > On Sat 09-06-12 14:29:56, Aneesh Kumar K.V wrote:
>> >> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>> >> 
>> >> This patchset add the charge and uncharge routines for hugetlb cgroup.
>> >> This will be used in later patches when we allocate/free HugeTLB
>> >> pages.
>> >
>> > Please describe the locking rules.
>> 
>> All the update happen within hugetlb_lock.
>
> Yes, I figured but it is definitely worth mentioning in the patch
> description.

Done.

>
> [...]
>> >> +void hugetlb_cgroup_commit_charge(int idx, unsigned long nr_pages,
>> >> +				  struct hugetlb_cgroup *h_cg,
>> >> +				  struct page *page)
>> >> +{
>> >> +	if (hugetlb_cgroup_disabled() || !h_cg)
>> >> +		return;
>> >> +
>> >> +	spin_lock(&hugetlb_lock);
>> >> +	if (hugetlb_cgroup_from_page(page)) {
>> >
>> > How can this happen? Is it possible that two CPUs are trying to charge
>> > one page?
>> 
>> That is why I added that. I looked at the alloc_huge_page, and I
>> don't see we would end with same page from different CPUs but then
>> we have similar checks in memcg, where we drop the charge if we find
>> the page cgroup already used.
>
> Yes but memcg is little bit more complicated than hugetlb which has
> which doesn't have to cope with async charges. Hugetlb allocation is
> serialized by hugetlb_lock so only one caller gets the page.
> I do not think the check is required here or add a comment explaining
> how it can happen.
>

updated.

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

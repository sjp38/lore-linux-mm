Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id ADE786B0104
	for <linux-mm@kvack.org>; Mon, 11 Jun 2012 06:17:44 -0400 (EDT)
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 11 Jun 2012 10:08:56 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5BAHXSF46792746
	for <linux-mm@kvack.org>; Mon, 11 Jun 2012 20:17:34 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5BAHWWS024322
	for <linux-mm@kvack.org>; Mon, 11 Jun 2012 20:17:33 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH -V8 15/16] hugetlb/cgroup: migrate hugetlb cgroup info from oldpage to new page during migration
In-Reply-To: <20120611092424.GJ12402@tiehlicka.suse.cz>
References: <1339232401-14392-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1339232401-14392-16-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20120611092424.GJ12402@tiehlicka.suse.cz>
Date: Mon, 11 Jun 2012 15:47:28 +0530
Message-ID: <878vfu5f0n.fsf@skywalker.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, rientjes@google.com, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

Michal Hocko <mhocko@suse.cz> writes:

> On Sat 09-06-12 14:30:00, Aneesh Kumar K.V wrote:
>> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>> 
>> With HugeTLB pages, hugetlb cgroup is uncharged in compound page
>> destructor.  Since we are holding a hugepage reference,
>
> Who is holding that reference? I do not see anybody calling get_page in
> this patch...
>

soft_offline_huge_page takes the reference. It does the final
put_page(hpage) there.

>> we can be sure that old page won't get uncharged till the last
>> put_page().
>> 

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

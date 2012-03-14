Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 2854C6B004A
	for <linux-mm@kvack.org>; Wed, 14 Mar 2012 06:48:46 -0400 (EDT)
Received: from /spool/local
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 14 Mar 2012 16:17:34 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q2EAlMpP843820
	for <linux-mm@kvack.org>; Wed, 14 Mar 2012 16:17:23 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q2EGHw1u014372
	for <linux-mm@kvack.org>; Thu, 15 Mar 2012 03:17:59 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH -V3 3/8] hugetlb: add charge/uncharge calls for HugeTLB alloc/free
In-Reply-To: <20120313143654.5dd1243d.akpm@linux-foundation.org>
References: <1331622432-24683-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1331622432-24683-4-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20120313143654.5dd1243d.akpm@linux-foundation.org>
Date: Wed, 14 Mar 2012 16:17:21 +0530
Message-ID: <87r4wv8nnq.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, aarcange@redhat.com, mhocko@suse.cz, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

On Tue, 13 Mar 2012 14:36:54 -0700, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Tue, 13 Mar 2012 12:37:07 +0530
> "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:
> 
> > +		return ERR_PTR(-VM_FAULT_SIGBUS);
> 
> whee, so we have (ab)used the err.h infrastructure to carry
> VM_FAULT_foo codes, thus creating a secret requirement that the
> VM_FAULT_foo values not exceed MAX_ERRNO.
> 
> What a hack, whodidthat?

e0dcd8a05be438b3d2e49ef61441ea3a463663f8. We only do that in hugetlb. I
will add a cleanup patch that will return proper error and map them in
the caller to return SIGBUS.

-aneesh 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

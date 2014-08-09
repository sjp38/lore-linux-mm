Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id A754E6B0036
	for <linux-mm@kvack.org>; Sat,  9 Aug 2014 17:34:49 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id rd3so9008791pab.40
        for <linux-mm@kvack.org>; Sat, 09 Aug 2014 14:34:49 -0700 (PDT)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id cc11si5599972pdb.101.2014.08.09.14.34.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 09 Aug 2014 14:34:48 -0700 (PDT)
Received: by mail-pa0-f53.google.com with SMTP id rd3so8920579pab.26
        for <linux-mm@kvack.org>; Sat, 09 Aug 2014 14:34:48 -0700 (PDT)
Date: Sat, 9 Aug 2014 14:34:46 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch v2] mm, hugetlb_cgroup: align hugetlb cgroup limit to
 hugepage size
In-Reply-To: <87mwbem0zo.fsf@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.02.1408091434280.17896@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1408071333001.1762@chino.kir.corp.google.com> <alpine.DEB.2.02.1408081507180.15603@chino.kir.corp.google.com> <87mwbem0zo.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, 9 Aug 2014, Aneesh Kumar K.V wrote:

> > diff --git a/mm/hugetlb_cgroup.c b/mm/hugetlb_cgroup.c
> > --- a/mm/hugetlb_cgroup.c
> > +++ b/mm/hugetlb_cgroup.c
> > @@ -275,6 +275,7 @@ static ssize_t hugetlb_cgroup_write(struct kernfs_open_file *of,
> >  		ret = res_counter_memparse_write_strategy(buf, &val);
> >  		if (ret)
> >  			break;
> > +		val = ALIGN(val, 1ULL << huge_page_shift(&hstates[idx]));
> 
> Do we really need ULL ? max value should fit in unsigned long right ?
> 

I usually just go for type agreement.

> >  		ret = res_counter_set_limit(&h_cg->hugepage[idx], val);
> >  		break;
> >  	default:
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

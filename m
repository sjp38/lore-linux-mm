Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id B26BA6B0038
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 22:02:22 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id f188so470899275pgc.1
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 19:02:22 -0800 (PST)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0085.outbound.protection.outlook.com. [104.47.0.85])
        by mx.google.com with ESMTPS id v23si62196105pgc.42.2016.11.29.19.02.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 29 Nov 2016 19:02:21 -0800 (PST)
Date: Wed, 30 Nov 2016 11:02:01 +0800
From: Huang Shijie <shijie.huang@arm.com>
Subject: Re: [PATCH V2 fix 5/6] mm: hugetlb: add a new function to allocate a
 new gigantic page
Message-ID: <20161130030159.GA18502@sha-win-210.asiapac.arm.com>
References: <1479107259-2011-6-git-send-email-shijie.huang@arm.com>
 <1479279304-31379-1-git-send-email-shijie.huang@arm.com>
 <f6fc93b4-5c1c-bbab-7c74-a0d60d4afc84@suse.cz>
 <20161129090322.GB16569@sha-win-210.asiapac.arm.com>
 <777f7e0c-c04b-77c3-b866-0787bad32aa8@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <777f7e0c-c04b-77c3-b866-0787bad32aa8@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: akpm@linux-foundation.org, catalin.marinas@arm.com, n-horiguchi@ah.jp.nec.com, mhocko@suse.com, kirill.shutemov@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com, gerald.schaefer@de.ibm.com, mike.kravetz@oracle.com, linux-mm@kvack.org, will.deacon@arm.com, steve.capper@arm.com, kaly.xin@arm.com, nd@arm.com, linux-arm-kernel@lists.infradead.org

On Tue, Nov 29, 2016 at 11:50:37AM +0100, Vlastimil Babka wrote:
> > > > +	if (!vma) {
> > > > +		if (nid == NUMA_NO_NODE) {
> > > > +			if (!init_nodemask_of_mempolicy(nodes_allowed)) {
> > > > +				NODEMASK_FREE(nodes_allowed);
> > > > +				nodes_allowed = &node_states[N_MEMORY];
> > > > +			}
> > > > +		} else if (nodes_allowed) {
> > The check is here.
> 
> It's below a possible usage of nodes_allowed as an argument of
> init_nodemask_of_mempolicy(mask). Which does
Sorry, I missed that.
> 
>         if (!(mask && current->mempolicy))
>                 return false;
> 
> which itself looks like an error at first sight :)
Yes. I agree.
> 
> > Do we really need to re-arrange the code here for the explicit check? :)
> 
> We don't need it *now* to be correct, but I still find it fragile. Also it
> mixes up the semantic of NULL as a conscious "default" value, and NULL as
> a side-effect of memory allocation failure. Nothing good can come from that
> in the long term :)
Okay, I think we do have the need to do the NULL check for
@nodes_allowed. :)

Thanks
Huang Shijie

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

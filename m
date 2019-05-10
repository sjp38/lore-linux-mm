Return-Path: <SRS0=iTus=TK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8F32FC04A6B
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 16:16:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 293452070D
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 16:16:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="jTF0ls4c"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 293452070D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7B1136B0003; Fri, 10 May 2019 12:16:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 762356B0005; Fri, 10 May 2019 12:16:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6294C6B0006; Fri, 10 May 2019 12:16:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4148F6B0003
	for <linux-mm@kvack.org>; Fri, 10 May 2019 12:16:38 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id v11so4550338ion.22
        for <linux-mm@kvack.org>; Fri, 10 May 2019 09:16:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=ikyWD5tw3+Fa2klAswpQ3zG257Y/SYQKpSWVthHNaDQ=;
        b=Vvbrn6cCNpUuS2WB0IvBnYshn5rnVKPUkiOf3SFbb9maJOZh1FnDvPKV/srYxzAeDW
         q2+Lrk96c8h0ai3tsHp3ZPNdhIs3G+6RSbyrck1NTk+P/fGVSR9dYY8gYWd1z5tr97lK
         YLyJwPek9lr+kN8EmQzVvwVuyK+cB9Q0aD6Xoys3N+brDZnV+EM7kWVI+RbDPWSmorRR
         jW2P5+nR7SwRQR8x5a2O6FmtHaGr0CfiQuONzp53QFUsIubvo1RtK2/gFRb5mVfZTKfE
         QtogutkOf4iNYzHkksjWFpFmEzFzCKrlWa+fsUSNpA5HJE06xlQW/9cKcXi98LM4FJ/y
         RNyw==
X-Gm-Message-State: APjAAAX/uG313L2yQd/Ff4M8s0aeToKqC2QzTJm5Bt44v6HLhHnh3G41
	dGI55m7UpCK6vVmqFQtI0vmDQo+eF76pC/n4dXXG9AHL6y0USzFIzq5YtxDaJpNK3w5MZm9L0Ks
	weiCndj2wcbov/R4+q3i6vwTM/9ciS0Yn4bAptHdMw0V2WqgEhSxnipHRq/garTd/uQ==
X-Received: by 2002:a24:8d42:: with SMTP id w63mr8399579itd.114.1557504997956;
        Fri, 10 May 2019 09:16:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz5l/DpBJ92jKvx3tL3y+jmZMfS7ndSz9+pJybbtKhkDtU9IXWitfYr5B2fyHVWS0A9rQv+
X-Received: by 2002:a24:8d42:: with SMTP id w63mr8399495itd.114.1557504997100;
        Fri, 10 May 2019 09:16:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557504997; cv=none;
        d=google.com; s=arc-20160816;
        b=Goy8u9RTAWiKiM+yEGpM6BEZq6ZyVn7lxX7hJhxuW42eIE5v0rM4YTwhkbL+LSOojy
         al4yS2kZh1Uby2i9jLklRcEg78SyKrexKfvMhw/BvIudlg/HKbH36tqQ6x1FGBaxwnki
         Wytz6d+Lx1ySUFMbmWBjkV6HUtrbHFEuAsDvmPCmkju+q1Kb4qMll/zgflc3LS93oTZF
         L7dcXcf6llFUhmLCx+Kso9eWINQ4UF96EJF0q/z/CC6gjsuE4lfBBfyIlBwVU7zWeTc6
         ySSc6y/9faIGjOHS70fo3Okcu1lTPf9gGXId+ty0KkjJ7UkCltdt/Wuy3dsRnoAYPzRC
         T/PA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=ikyWD5tw3+Fa2klAswpQ3zG257Y/SYQKpSWVthHNaDQ=;
        b=i08D4PY/rCKkXNHcYcGbi86+nr76tHhHUK4l1lRYpPlaVpjsbNUhzzaw0aDY7x9Rcl
         6MJsW/DRc7THRGkozq9a/2I3zWjKAawTKEFW/9MEiJZJFtx56gIEUVrAssfu6Eo/eq40
         BKN/lAulniSRgvp6tzgNHOE6lWN309Y5nzW31B3RYFCrySSUrIgZC1Z8A/rdRSSyFidA
         BaurKcgR/UI/P5HTOTOmvxgis5W+vkypGuT/Gap1IwXFQM4+4gPpJtQoTaQ4J5KC4L5P
         ovK6Pgb8HplH4SsE9n9HquZnHVBz+mYCgIym4qaUMP40dvGc15tYPYc/T8L44w4pyWfG
         9iug==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=jTF0ls4c;
       spf=pass (google.com: domain of larry.bassel@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=larry.bassel@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id j196si3819856itb.62.2019.05.10.09.16.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 May 2019 09:16:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of larry.bassel@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=jTF0ls4c;
       spf=pass (google.com: domain of larry.bassel@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=larry.bassel@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4AG8faU027900;
	Fri, 10 May 2019 16:16:22 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=ikyWD5tw3+Fa2klAswpQ3zG257Y/SYQKpSWVthHNaDQ=;
 b=jTF0ls4cyPu4lSedw8dhdKuv+vpLCt0VH3bLgDV9dvGWnvAVyKs31jEKWxt23CxWULLe
 KdKut0Bqm/TJKO/jJzsWynABfRlBIs8SJs4xOeoYPDb3KD0IHG7KBeJo5FxJgkD+AhXw
 CFZOeUR/vri7jNs8vQaK2dJgqlPlpR8RMPBLJXtdvnovfc14TIJ+JFvbc6f+Fi9by9yA
 RWK/2h22VkMcoqAg4JfIVgk6812bBv2eGY1biLyyCsCZxQB2gRme7+xocJJq6CDx/Fnz
 MrTVuCkawwTYm0ebBeD30KgDpatU8Jk+d022WGuXpOS2WXl2+Vd4j5rJ6u5GvvCCouIE Jg== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by userp2130.oracle.com with ESMTP id 2s94bgj6dx-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 10 May 2019 16:16:21 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4AGFATp008060;
	Fri, 10 May 2019 16:16:21 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserp3020.oracle.com with ESMTP id 2schw0gr97-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 10 May 2019 16:16:21 +0000
Received: from abhmp0007.oracle.com (abhmp0007.oracle.com [141.146.116.13])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x4AGGIAk029191;
	Fri, 10 May 2019 16:16:18 GMT
Received: from ubuette (/75.80.107.76)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Fri, 10 May 2019 16:16:17 +0000
Date: Fri, 10 May 2019 09:16:07 -0700
From: Larry Bassel <larry.bassel@oracle.com>
To: Matthew Wilcox <willy@infradead.org>
Cc: Larry Bassel <larry.bassel@oracle.com>, mike.kravetz@oracle.com,
        dan.j.williams@intel.com, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org
Subject: Re: [PATCH, RFC 2/2] Implement sharing/unsharing of PMDs for FS/DAX
Message-ID: <20190510161607.GB27674@ubuette>
References: <1557417933-15701-1-git-send-email-larry.bassel@oracle.com>
 <1557417933-15701-3-git-send-email-larry.bassel@oracle.com>
 <20190509164914.GA3862@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190509164914.GA3862@bombadil.infradead.org>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9252 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1905100110
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9252 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905100110
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 09 May 19 09:49, Matthew Wilcox wrote:
> On Thu, May 09, 2019 at 09:05:33AM -0700, Larry Bassel wrote:
> > This is based on (but somewhat different from) what hugetlbfs
> > does to share/unshare page tables.
> 
> Wow, that worked out far more cleanly than I was expecting to see.

Yes, I was pleasantly surprised. As I've mentioned already, I 
think this is at least partially due to the nature of DAX.

> 
> > @@ -4763,6 +4763,19 @@ void adjust_range_if_pmd_sharing_possible(struct vm_area_struct *vma,
> >  				unsigned long *start, unsigned long *end)
> >  {
> >  }
> > +
> > +unsigned long page_table_shareable(struct vm_area_struct *svma,
> > +				   struct vm_area_struct *vma,
> > +				   unsigned long addr, pgoff_t idx)
> > +{
> > +	return 0;
> > +}
> > +
> > +bool vma_shareable(struct vm_area_struct *vma, unsigned long addr)
> > +{
> > +	return false;
> > +}
> 
> I don't think you need these stubs, since the only caller of them is
> also gated by MAY_SHARE_FSDAX_PMD ... right?

These are also called in mm/hugetlb.c, but those calls are gated by
CONFIG_ARCH_WANT_HUGE_PMD_SHARE. In fact if this is not set (though
it is the default), then one wouldn't get FS/DAX sharing even if
MAY_SHARE_FSDAX_PMD is set. I think that this isn't what we want
(perhaps the real question is how should these two config options interact?).
Removing the stubs would fix this and I will make that change.

Maybe these two functions should be moved into mm/memory.c as well.

> 
> > +	vma_interval_tree_foreach(svma, &mapping->i_mmap, idx, idx) {
> > +		if (svma == vma)
> > +			continue;
> > +
> > +		saddr = page_table_shareable(svma, vma, addr, idx);
> > +		if (saddr) {
> > +			spmd = huge_pmd_offset(svma->vm_mm, saddr,
> > +					       vma_mmu_pagesize(svma));
> > +			if (spmd) {
> > +				get_page(virt_to_page(spmd));
> > +				break;
> > +			}
> > +		}
> > +	}
> 
> I'd be tempted to reduce the indentation here:
> 
> 	vma_interval_tree_foreach(svma, &mapping->i_mmap, idx, idx) {
> 		if (svma == vma)
> 			continue;
> 
> 		saddr = page_table_shareable(svma, vma, addr, idx);
> 		if (!saddr)
> 			continue;
> 
> 		spmd = huge_pmd_offset(svma->vm_mm, saddr,
> 					vma_mmu_pagesize(svma));
> 		if (spmd)
> 			break;
> 	}
> 
> 
> > +	if (!spmd)
> > +		goto out;
> 
> ... and move the get_page() down to here, so we don't split the
> "when we find it" logic between inside and outside the loop.
> 
> 	get_page(virt_to_page(spmd));
> 
> > +
> > +	ptl = pmd_lockptr(mm, spmd);
> > +	spin_lock(ptl);
> > +
> > +	if (pud_none(*pud)) {
> > +		pud_populate(mm, pud,
> > +			    (pmd_t *)((unsigned long)spmd & PAGE_MASK));
> > +		mm_inc_nr_pmds(mm);
> > +	} else {
> > +		put_page(virt_to_page(spmd));
> > +	}
> > +	spin_unlock(ptl);
> > +out:
> > +	pmd = pmd_alloc(mm, pud, addr);
> > +	i_mmap_unlock_write(mapping);
> 
> I would swap these two lines.  There's no need to hold the i_mmap_lock
> while allocating this PMD, is there?  I mean, we don't for the !may_share
> case.
> 

These were done in the style of functions already in mm/hugetlb.c and I was
trying to change as little as necessary in my copy of those. I agree that
these are good suggestions. One could argue that if these changes
were made, they should also be made in mm/hugetlb.c, though
this is perhaps beyond the scope of getting FS/DAX PMD sharing
implemented -- your thoughts?

Thanks for the review, I'll wait a few more days for other comments
and then send out a v2.

Larry


Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1D0EEC43331
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 18:59:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D9F98206BA
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 18:59:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="TGgiknxf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D9F98206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8F9266B0005; Thu,  5 Sep 2019 14:59:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8A8846B0007; Thu,  5 Sep 2019 14:59:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7BF6F6B0008; Thu,  5 Sep 2019 14:59:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0230.hostedemail.com [216.40.44.230])
	by kanga.kvack.org (Postfix) with ESMTP id 5C6BA6B0005
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 14:59:20 -0400 (EDT)
Received: from smtpin27.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id F07E655FB2
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 18:59:19 +0000 (UTC)
X-FDA: 75901780038.27.cook17_8ba543c7b8562
X-HE-Tag: cook17_8ba543c7b8562
X-Filterd-Recvd-Size: 2635
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf13.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 18:59:19 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=8h3UhHiEI4pJMKlOZTLVFE7Tkc+/1Cl1/3KhMdpiUok=; b=TGgiknxf0qcRw92OkyIuYcJY1
	ARsWI5gB5o1gK+YcuC1pa3ViRvQXo09k4k8TDCfD+AQ/KAAdB74dK7r/29HSYR/llqLciCQB1LzGT
	EmHraC/V/dDuWS+cCvlk7I/GLVIXElKWMSLBKEMgyWBycpyRW5Mgc6FybOLmes9FnCudHFzWTIHTX
	PPxBtW0u1kNMy7juXrwfpRPAhTyvS2eFK9iCo4GxNRAryBCnMJHwbexMrhocGNow7oxfm1e8Y+KxX
	rPbSWTqG5JafAsjItBQMTlBRJZETe2d6DpCP2BOYasS6p5kMlZ+dDS7hLhlAiaNXoVNoTcaPPdfkO
	ZZAQXDY/Q==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1i5wyM-0006TE-8X; Thu, 05 Sep 2019 18:59:10 +0000
Date: Thu, 5 Sep 2019 11:59:10 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: akpm@linux-foundation.org, rcampbell@nvidia.com, jglisse@redhat.com,
	mhocko@suse.com, aneesh.kumar@linux.ibm.com, peterz@infradead.org,
	airlied@redhat.com, thellstrom@vmware.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm/memory.c: Convert to use vmf_error()
Message-ID: <20190905185910.GS29434@bombadil.infradead.org>
References: <1567708980-8804-1-git-send-email-jrdr.linux@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1567708980-8804-1-git-send-email-jrdr.linux@gmail.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Sep 06, 2019 at 12:13:00AM +0530, Souptick Joarder wrote:
> +++ b/mm/memory.c
> @@ -1750,13 +1750,10 @@ static vm_fault_t __vm_insert_mixed(struct vm_area_struct *vma,
>  	} else {
>  		return insert_pfn(vma, addr, pfn, pgprot, mkwrite);
>  	}
> -
> -	if (err == -ENOMEM)
> -		return VM_FAULT_OOM;
> -	if (err < 0 && err != -EBUSY)
> -		return VM_FAULT_SIGBUS;
> -
> -	return VM_FAULT_NOPAGE;
> +	if (!err || err == -EBUSY)
> +		return VM_FAULT_NOPAGE;
> +	else
> +		return vmf_error(err);
>  }

My plan is to convert insert_page() to return a VM_FAULT error code like
insert_pfn() does.  Need to finish off the vm_insert_page() conversions
first ;-)


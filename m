Return-Path: <SRS0=B4NV=XI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B004AC49ED7
	for <linux-mm@archiver.kernel.org>; Fri, 13 Sep 2019 15:18:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 760F321479
	for <linux-mm@archiver.kernel.org>; Fri, 13 Sep 2019 15:18:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="HGJfCy21"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 760F321479
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EC7A46B0003; Fri, 13 Sep 2019 11:18:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E78AB6B0006; Fri, 13 Sep 2019 11:18:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D8CF66B0007; Fri, 13 Sep 2019 11:18:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0022.hostedemail.com [216.40.44.22])
	by kanga.kvack.org (Postfix) with ESMTP id B2AC56B0003
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 11:18:11 -0400 (EDT)
Received: from smtpin22.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 58DD782437D2
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 15:18:11 +0000 (UTC)
X-FDA: 75930253182.22.glass86_81a56a0780431
X-HE-Tag: glass86_81a56a0780431
X-Filterd-Recvd-Size: 3110
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf13.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 15:18:10 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Transfer-Encoding
	:Content-Type:MIME-Version:References:Message-ID:Subject:Cc:To:From:Date:
	Sender:Reply-To:Content-ID:Content-Description:Resent-Date:Resent-From:
	Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=fxdx8ELT74pyYGT61OLGflIw6z6NXtnHEx3y22zF9/I=; b=HGJfCy214Ht+AD4xBmFC2EHL/h
	RGMiZnEGOa0ZkY+vilO/vwXrwlw5aVSIvlxTJlhfy35kx2Hk/aCz/fPXBIfh0u4xiRil59kS16WqN
	CY+c/HDv6hZES8flPhraJi79Tpz9SEavFg1fZFXMRI5mwNNJdUBiCFJFQIYl1DqSJWaXVqwotLrkI
	660Dzqxfp3iTpjh7kUAAzqrFPM72+Z6LiD0P9chN7sJkU1s05NXxtGy9NxaZYefRN/RG1jJscJbE4
	6htV+dd2KCxAB9XypgpTU4/6FN8Ci4QOP9ZyPmtmR7pOb2QB5fu/qm4PQs4IiI5fEeSy3ft9D+awP
	t+Sl2VEQ==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92.2 #3 (Red Hat Linux))
	id 1i8nKl-0006KN-Pf; Fri, 13 Sep 2019 15:18:03 +0000
Date: Fri, 13 Sep 2019 08:18:03 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Thomas =?iso-8859-1?Q?Hellstr=F6m_=28VMware=29?= <thomas_os@shipmail.org>
Cc: linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org,
	linux-mm@kvack.org, pv-drivers@vmware.com,
	linux-graphics-maintainer@vmware.com,
	Thomas Hellstrom <thellstrom@vmware.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Will Deacon <will.deacon@arm.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Rik van Riel <riel@surriel.com>, Minchan Kim <minchan@kernel.org>,
	Michal Hocko <mhocko@suse.com>, Huang Ying <ying.huang@intel.com>,
	Souptick Joarder <jrdr.linux@gmail.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>,
	Christoph Hellwig <hch@infradead.org>
Subject: Re: [RFC PATCH 3/7] drm/ttm: TTM fault handler helpers
Message-ID: <20190913151803.GO29434@bombadil.infradead.org>
References: <20190913093213.27254-1-thomas_os@shipmail.org>
 <20190913093213.27254-4-thomas_os@shipmail.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20190913093213.27254-4-thomas_os@shipmail.org>
User-Agent: Mutt/1.11.4 (2019-03-13)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Sep 13, 2019 at 11:32:09AM +0200, Thomas Hellstr=F6m (VMware) wro=
te:
> +vm_fault_t ttm_bo_vm_fault_reserved(struct vm_fault *vmf,
> +				    pgprot_t prot,
> +				    pgoff_t num_prefault)
> +{
> +	struct vm_area_struct *vma =3D vmf->vma;
> +	struct vm_area_struct cvma =3D *vma;
> +	struct ttm_buffer_object *bo =3D (struct ttm_buffer_object *)
> +	    vma->vm_private_data;

It's a void *.  There's no need to cast it.

	struct ttm_buffer_object *bo =3D vma->vm_private_data;

conveys exactly the same information to both the reader and the compiler,
except it's all on one line instead of split over two.



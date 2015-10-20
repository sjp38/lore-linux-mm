Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 89D8482F64
	for <linux-mm@kvack.org>; Tue, 20 Oct 2015 12:03:30 -0400 (EDT)
Received: by wicfx6 with SMTP id fx6so52822368wic.1
        for <linux-mm@kvack.org>; Tue, 20 Oct 2015 09:03:30 -0700 (PDT)
Received: from theia.8bytes.org (8bytes.org. [2a01:238:4383:600:38bc:a715:4b6d:a889])
        by mx.google.com with ESMTPS id eq6si4839546wjd.12.2015.10.20.09.03.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Oct 2015 09:03:28 -0700 (PDT)
Date: Tue, 20 Oct 2015 18:03:28 +0200
From: Joerg Roedel <joro@8bytes.org>
Subject: Re: [RFC PATCH] iommu/vt-d: Add IOTLB flush support for kernel
 addresses
Message-ID: <20151020160328.GV27420@8bytes.org>
References: <1445356379.4486.56.camel@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1445356379.4486.56.camel@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Woodhouse <dwmw2@infradead.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, iommu@lists.linux-foundation.org, Sudeep Dutt <sudeep.dutt@intel.com>

Hi David,

On Tue, Oct 20, 2015 at 04:52:59PM +0100, David Woodhouse wrote:
>  void flush_tlb_kernel_range(unsigned long start, unsigned long end)
>  {
> +	intel_iommu_flush_kernel_pasid(start, end);

A more generic naming would be good, and probably expose it through a
function in the IOMMU-API.

> +void intel_iommu_flush_kernel_pasid(unsigned long start, unsigned long end)
> +{
> +	struct dmar_drhd_unit *drhd;
> +	struct intel_iommu *iommu;
> +	unsigned long pages;

And I think, as a performance optimiztion, we should bail out early here
if the pasid has no users.



	Joerg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

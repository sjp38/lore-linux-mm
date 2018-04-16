Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 29E546B0007
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 05:07:11 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id k22so10140744qtm.4
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 02:07:11 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id g12si11914701qtg.292.2018.04.16.02.07.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Apr 2018 02:07:10 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w3G95tMg098916
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 05:07:09 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2hcqs5b81c-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 05:07:08 -0400
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 16 Apr 2018 10:07:05 +0100
Subject: Re: [PATCH 02/12] iommu-helper: unexport iommu_area_alloc
References: <20180415145947.1248-1-hch@lst.de>
 <20180415145947.1248-3-hch@lst.de>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Mon, 16 Apr 2018 14:36:56 +0530
MIME-Version: 1.0
In-Reply-To: <20180415145947.1248-3-hch@lst.de>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <1cedfc7e-9168-47bd-cc6a-0557b92eb37b@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, iommu@lists.linux-foundation.org
Cc: x86@kernel.org, linux-block@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-ide@vger.kernel.org, linux-mips@linux-mips.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org

On 04/15/2018 08:29 PM, Christoph Hellwig wrote:
> This function is only used by built-in code.
> 
> Reviewed-by: Christoph Hellwig <hch@lst.de>

Reviewed-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>

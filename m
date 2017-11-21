Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id B3E6F6B025E
	for <linux-mm@kvack.org>; Tue, 21 Nov 2017 18:05:06 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id v186so1880392wma.9
        for <linux-mm@kvack.org>; Tue, 21 Nov 2017 15:05:06 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id z1si11483899wre.339.2017.11.21.15.05.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Nov 2017 15:05:05 -0800 (PST)
Date: Tue, 21 Nov 2017 15:05:01 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 1/4] mm: introduce get_user_pages_longterm
Message-Id: <20171121150501.d4d811a66444cb5c9cb85bf2@linux-foundation.org>
In-Reply-To: <151068939435.7446.13560129395419350737.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <151068938905.7446.12333914805308312313.stgit@dwillia2-desk3.amr.corp.intel.com>
	<151068939435.7446.13560129395419350737.stgit@dwillia2-desk3.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Hellwig <hch@lst.de>, stable@vger.kernel.org, linux-nvdimm@lists.01.org

On Tue, 14 Nov 2017 11:56:34 -0800 Dan Williams <dan.j.williams@intel.com> wrote:

> Until there is a solution to the dma-to-dax vs truncate problem it is
> not safe to allow long standing memory registrations against
> filesytem-dax vmas. Device-dax vmas do not have this problem and are
> explicitly allowed.
> 
> This is temporary until a "memory registration with layout-lease"
> mechanism can be implemented for the affected sub-systems (RDMA and
> V4L2).

Sounds like that will be unpleasant.  Do we really need it to be that
complex?  Can we get away with simply failing the get_user_pages()
request?  Or are there significant usecases for RDMA and V4L to play
with DAX memory?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id EFC1F280260
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 07:39:14 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id l8so88488583iti.6
        for <linux-mm@kvack.org>; Mon, 21 Nov 2016 04:39:14 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 134si13805837ioc.97.2016.11.21.04.39.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Nov 2016 04:39:14 -0800 (PST)
Date: Mon, 21 Nov 2016 07:39:10 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [HMM v13 05/18] mm/ZONE_DEVICE/devmem_pages_remove: allow early
 removal of device memory
Message-ID: <20161121123910.GE2392@redhat.com>
References: <1479493107-982-1-git-send-email-jglisse@redhat.com>
 <1479493107-982-6-git-send-email-jglisse@redhat.com>
 <5832CE7A.3060802@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <5832CE7A.3060802@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Mon, Nov 21, 2016 at 04:07:46PM +0530, Anshuman Khandual wrote:
> On 11/18/2016 11:48 PM, Jerome Glisse wrote:
> > HMM wants to remove device memory early before device tear down so add an
> > helper to do that.
> 
> Could you please explain why HMM wants to remove device memory before
> device tear down ?
> 

Some device driver want to manage memory for several physical devices from a
single fake device driver. Because it fits their driver architecture better
and those physical devices can have dedicated link between them.

Issue is that the fake device driver can outlive any of the real device for a
long time so we want to be able to remove device memory before the fake device
goes away to free up resources early.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

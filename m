Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id C5A5B6B025F
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 15:36:22 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 76so4080626pfr.3
        for <linux-mm@kvack.org>; Wed, 18 Oct 2017 12:36:22 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id f5sor2787662pgc.136.2017.10.18.12.36.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 18 Oct 2017 12:36:21 -0700 (PDT)
Date: Thu, 19 Oct 2017 06:36:07 +1100
From: Balbir Singh <bsingharora@gmail.com>
Subject: Re: [rfc 1/2] mm/hmm: Allow smaps to see zone device public pages
Message-ID: <20171019063607.0d9010e4@MiWiFi-R3-srv>
In-Reply-To: <8d49e1b3-a342-c06e-8e03-e0da2b34ef43@linux.vnet.ibm.com>
References: <20171018063123.21983-1-bsingharora@gmail.com>
	<8d49e1b3-a342-c06e-8e03-e0da2b34ef43@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: jglisse@redhat.com, linux-mm@kvack.org, mhocko@suse.com

On Wed, 18 Oct 2017 12:26:25 +0530
Anshuman Khandual <khandual@linux.vnet.ibm.com> wrote:

> On 10/18/2017 12:01 PM, Balbir Singh wrote:
> > vm_normal_page() normally does not return zone device public
> > pages. In the absence of the visibility the output from smaps  
> 
> It never does, as it calls _vm_normal_page() with with_public
> _device = false, which skips all ZONE_DEVICE pages which are
> MEMORY_DEVICE_PUBLIC.

Yes, probably the use of normally is not required.

> 
> > is limited and confusing. It's hard to figure out where the
> > pages are. This patch uses _vm_normal_page() to expose them  
> 
> Just a small nit, 'uses _vm_normal_page() with with_public_
> device as true'.

OK, I'll reword.

> 
> > for accounting  
> 
> Makes sense. It will help to have a small snippet of smaps output
> with and without this patch demonstrating the difference. That
> apart change looks good.
> 

I can do that if its helpful

Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

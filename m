Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id A2F7A6B0005
	for <linux-mm@kvack.org>; Mon,  5 Feb 2018 08:45:46 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id h5so19930241pgv.21
        for <linux-mm@kvack.org>; Mon, 05 Feb 2018 05:45:46 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id y12si723623pff.230.2018.02.05.05.45.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Feb 2018 05:45:45 -0800 (PST)
Subject: Re: Possible reasons of CMA allocation failure
From: Alexey Skidanov <alexey.skidanov@intel.com>
References: <10f52913-ad8b-4fd2-5e55-47aa46c48c0d@intel.com>
Message-ID: <d566a6df-b0d7-8ab6-69dc-ae6077cee75b@intel.com>
Date: Mon, 5 Feb 2018 15:46:13 +0200
MIME-Version: 1.0
In-Reply-To: <10f52913-ad8b-4fd2-5e55-47aa46c48c0d@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, labbott@redhat.com



On 02/05/2018 12:58 AM, Alexey Skidanov wrote:
> Hello,
> 
> On x86 machine with 16GB RAM installed, I reserved 1 GB area for CMA:
> [    0.000000] cma: Reserved 1024 MiB at 0x00000003fcc00000
> 
> Some time after the boot, CMa failed to allocate chunk of memory while
> there are enough contiguous pages:
> 
> [  392.132392] cma: cma_alloc: alloc failed, req-size: 200000 pages,
> ret: -16
> [  392.132393] cma: number of available pages:
> 6@8314+9@8343+9@8375+253648@8496=> 253672 free of 262144 total pages
> [  392.132398] cma: cma_alloc(): returned (null)
> 
> What are the possible reasons for such failure (besides the pinned user
> allocated pages) ?
> 
> Thanks,
> Alexey
> 

After some debugging - the page migration failed because of there is the
page with _refcount 2, _mapcount -1. Seems like it's pinned?

Thanks,
Alexey

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

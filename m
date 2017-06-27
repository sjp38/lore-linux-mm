Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 416A76B02F4
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 16:58:27 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id h134so26840457iof.1
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 13:58:27 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id g100si219163iod.30.2017.06.27.13.58.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Jun 2017 13:58:26 -0700 (PDT)
Subject: Re: [PATCH RFC] hugetlbfs 'noautofill' mount option
References: <326e38dd-b4a8-e0ca-6ff7-af60e8045c74@oracle.com>
 <b0efc671-0d7a-0aef-5646-a635478c31b0@oracle.com>
 <7ff6fb32-7d16-af4f-d9d5-698ab7e9e14b@intel.com>
 <03127895-3c5a-5182-82de-3baa3116749e@oracle.com>
 <22557bf3-14bb-de02-7b1b-a79873c583f1@intel.com>
 <7677d20e-5d53-1fb7-5dac-425edda70b7b@oracle.com>
 <48a544c4-61b3-acaf-0386-649f073602b6@intel.com>
 <476ea1b6-36d1-bc86-fa99-b727e3c2650d@oracle.com>
 <20170509085825.GB32555@infradead.org>
 <1031e0d4-cdbb-db8b-dae7-7c733921e20e@oracle.com>
 <20170616131554.GD11676@redhat.com>
 <47ea78b4-3b14-264e-2c92-e5e507fd3cba@oracle.com>
From: Prakash Sangappa <prakash.sangappa@oracle.com>
Message-ID: <b769dc7b-2486-b703-6346-1f80a092cc3f@oracle.com>
Date: Tue, 27 Jun 2017 13:57:48 -0700
MIME-Version: 1.0
In-Reply-To: <47ea78b4-3b14-264e-2c92-e5e507fd3cba@oracle.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>, Dave Hansen <dave.hansen@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mike Rapoport <rppt@linux.vnet.ibm.com>, Mike Kravetz <mike.kravetz@oracle.com>



On 6/20/17 4:35 PM, Prakash Sangappa wrote:
>
>
> On 6/16/17 6:15 AM, Andrea Arcangeli wrote:
>> Adding a single if (ctx->feature & UFFD_FEATURE_SIGBUS) goto out,
>> branch for this corner case to handle_userfault() isn't great and the
>> hugetlbfs mount option is absolutely zero cost to the handle_userfault
>> which is primarily why I'm not against it.. although it's not going to
>> be measurable so it would be ok also to add such feature.
>
>
> If implementing UFFD_FEATURE_SIGBUS is preferred instead of the mount 
> option, I could look into that.
>
Implementing UFFD_FEATURE_SIGBUS seems reasonable.

I wanted to note here on this thread that I sent out a seperate
RFC patch review for adding UFFD_FEATURE_SIGBUS.

See,
http://marc.info/?l=linux-mm&m=149857975906880&w=2


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

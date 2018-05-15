Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9EC576B026B
	for <linux-mm@kvack.org>; Tue, 15 May 2018 06:46:23 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id l85-v6so12829115pfb.18
        for <linux-mm@kvack.org>; Tue, 15 May 2018 03:46:23 -0700 (PDT)
Received: from mx142.netapp.com (mx142.netapp.com. [2620:10a:4005:8000:2306::b])
        by mx.google.com with ESMTPS id i190-v6si9349550pge.408.2018.05.15.03.46.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 May 2018 03:46:22 -0700 (PDT)
Subject: Re: [PATCH] mm: Add new vma flag VM_LOCAL_CPU
References: <0efb5547-9250-6b6c-fe8e-cf4f44aaa5eb@netapp.com>
 <1d5f676f-b5d1-3ad3-c7a5-25b390c0e44e@netapp.com>
 <20180515070856.GA8522@infradead.org>
From: Boaz Harrosh <boazh@netapp.com>
Message-ID: <11632615-e6a1-11d0-ac8f-3d66e49a23d3@netapp.com>
Date: Tue, 15 May 2018 13:45:55 +0300
MIME-Version: 1.0
In-Reply-To: <20180515070856.GA8522@infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Jeff Moyer <jmoyer@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H.
 Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@linux.intel.com>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, Amit Golander <Amit.Golander@netapp.com>

On 15/05/18 10:08, Christoph Hellwig wrote:
> On Mon, May 14, 2018 at 09:26:13PM +0300, Boaz Harrosh wrote:
>> I am please pushing for this patch ahead of the push of ZUFS, because
>> this is the only patch we need from otherwise an STD Kernel.
>>
>> We are partnering with Distro(s) to push ZUFS out-of-tree to beta clients
>> to try and stabilize such a big project before final submission and
>> an ABI / on-disk freeze.
>>
> 
> Please stop this crap.  If you want any new kernel functionality send
> it together with a user.  Even more so for something as questionanble
> and hairy as this.
> 
> With a stance like this you disqualify yourself.
> 

OK thank you I see your point. I will try to push a user ASAP.

Thanks
Boaz

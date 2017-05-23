Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7C7956B0279
	for <linux-mm@kvack.org>; Tue, 23 May 2017 04:38:19 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id l9so14978945wre.12
        for <linux-mm@kvack.org>; Tue, 23 May 2017 01:38:19 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 88si15803991wrs.18.2017.05.23.01.38.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 23 May 2017 01:38:18 -0700 (PDT)
Subject: Re: [PATCH] mm: Define KB, MB, GB, TB in core VM
References: <20170522111742.29433-1-khandual@linux.vnet.ibm.com>
 <20170522141149.9ef84bb0713769f4af0383f0@linux-foundation.org>
 <20170523070227.GA27864@infradead.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <09a6bafa-5743-425e-8def-bd9219cd756c@suse.cz>
Date: Tue, 23 May 2017 10:38:17 +0200
MIME-Version: 1.0
In-Reply-To: <20170523070227.GA27864@infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 05/23/2017 09:02 AM, Christoph Hellwig wrote:
> On Mon, May 22, 2017 at 02:11:49PM -0700, Andrew Morton wrote:
>> On Mon, 22 May 2017 16:47:42 +0530 Anshuman Khandual <khandual@linux.vnet.ibm.com> wrote:
>>
>>> There are many places where we define size either left shifting integers
>>> or multiplying 1024s without any generic definition to fall back on. But
>>> there are couples of (powerpc and lz4) attempts to define these standard
>>> memory sizes. Lets move these definitions to core VM to make sure that
>>> all new usage come from these definitions eventually standardizing it
>>> across all places.
>>
>> Grep further - there are many more definitions and some may now
>> generate warnings.
>>
>> Newly including mm.h for these things seems a bit heavyweight.  I can't
>> immediately think of a more appropriate place.  Maybe printk.h or
>> kernel.h.
> 
> IFF we do these kernel.h is the right place.  And please also add the
> MiB & co variants for the binary versions right next to the decimal
> ones.

Those defined in the patch are binary, not decimal. Do we even need
decimal ones?

> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

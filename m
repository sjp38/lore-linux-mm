Received: from zps78.corp.google.com (zps78.corp.google.com [172.25.146.78])
	by smtp-out.google.com with ESMTP id l433mEMj030454
	for <linux-mm@kvack.org>; Wed, 2 May 2007 20:48:14 -0700
Received: from an-out-0708.google.com (andd14.prod.google.com [10.100.30.14])
	by zps78.corp.google.com with ESMTP id l433m9DX027624
	for <linux-mm@kvack.org>; Wed, 2 May 2007 20:48:09 -0700
Received: by an-out-0708.google.com with SMTP id d14so380127and
        for <linux-mm@kvack.org>; Wed, 02 May 2007 20:48:08 -0700 (PDT)
Message-ID: <b040c32a0705022048p6c08fd41wcca7ac628d4229bc@mail.gmail.com>
Date: Wed, 2 May 2007 20:48:08 -0700
From: "Ken Chen" <kenchen@google.com>
Subject: Re: cache-pipe-buf-page-address-for-non-highmem-arch.patch
In-Reply-To: <20070501020441.10b6a003.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070430162007.ad46e153.akpm@linux-foundation.org>
	 <20070501085431.GD14364@infradead.org>
	 <20070501020441.10b6a003.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

On 5/1/07, Andrew Morton <akpm@linux-foundation.org> wrote:
> Fair enough, it is a bit of an ugly thing.  And I see no measurements there
> on what the overall speedup was for any workload.
>
> Ken, which memory model was in use?  sparsemem?

discontigmem with config_numa on.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

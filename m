Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 94BD06B0003
	for <linux-mm@kvack.org>; Thu,  1 Feb 2018 10:35:02 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id g186so18090902pfb.11
        for <linux-mm@kvack.org>; Thu, 01 Feb 2018 07:35:02 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 139sor312136pfw.75.2018.02.01.07.35.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Feb 2018 07:35:01 -0800 (PST)
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] Killing reliance on struct page->mapping
References: <20180130004347.GD4526@redhat.com>
 <20180131165646.GI29051@ZenIV.linux.org.uk>
 <20180131174245.GE2912@redhat.com>
 <20180131175558.GA30522@ZenIV.linux.org.uk>
 <20180131181356.GG2912@redhat.com>
From: Jens Axboe <axboe@kernel.dk>
Message-ID: <35c2908e-b6ba-fc29-0a3c-15cb8cf00256@kernel.dk>
Date: Thu, 1 Feb 2018 08:34:58 -0700
MIME-Version: 1.0
In-Reply-To: <20180131181356.GG2912@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>, Al Viro <viro@ZenIV.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org, linux-block@vger.kernel.org

On 1/31/18 11:13 AM, Jerome Glisse wrote:
> That's one solution, another one is to have struct bio_vec store
> buffer_head pointer and not page pointer, from buffer_head you can
> find struct page and using buffer_head and struct page pointer you
> can walk the KSM rmap_item chain to find back the mapping. This
> would be needed on I/O error for pending writeback of a newly write
> protected page, so one can argue that the overhead of the chain lookup
> to find back the mapping against which to report IO error, is an
> acceptable cost.

Ehm nope. bio_vec is a generic container for pages, requiring
buffer_heads to be able to do IO would be insanity.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

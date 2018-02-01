Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 041C86B0006
	for <linux-mm@kvack.org>; Thu,  1 Feb 2018 11:00:18 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id r74so18277237iod.15
        for <linux-mm@kvack.org>; Thu, 01 Feb 2018 08:00:18 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z9sor684955ioe.66.2018.02.01.08.00.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Feb 2018 08:00:17 -0800 (PST)
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] Killing reliance on struct page->mapping
References: <20180130004347.GD4526@redhat.com>
 <20180131165646.GI29051@ZenIV.linux.org.uk>
 <20180131174245.GE2912@redhat.com>
 <20180131175558.GA30522@ZenIV.linux.org.uk>
 <20180131181356.GG2912@redhat.com>
 <35c2908e-b6ba-fc29-0a3c-15cb8cf00256@kernel.dk>
 <20180201155748.GA3085@redhat.com>
From: Jens Axboe <axboe@kernel.dk>
Message-ID: <0badeb21-c08b-80bf-6631-a18c67696f74@kernel.dk>
Date: Thu, 1 Feb 2018 09:00:13 -0700
MIME-Version: 1.0
In-Reply-To: <20180201155748.GA3085@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org, linux-block@vger.kernel.org

On 2/1/18 8:57 AM, Jerome Glisse wrote:
> On Thu, Feb 01, 2018 at 08:34:58AM -0700, Jens Axboe wrote:
>> On 1/31/18 11:13 AM, Jerome Glisse wrote:
>>> That's one solution, another one is to have struct bio_vec store
>>> buffer_head pointer and not page pointer, from buffer_head you can
>>> find struct page and using buffer_head and struct page pointer you
>>> can walk the KSM rmap_item chain to find back the mapping. This
>>> would be needed on I/O error for pending writeback of a newly write
>>> protected page, so one can argue that the overhead of the chain lookup
>>> to find back the mapping against which to report IO error, is an
>>> acceptable cost.
>>
>> Ehm nope. bio_vec is a generic container for pages, requiring
>> buffer_heads to be able to do IO would be insanity.
> 
> The extra pointer dereference would be killing performance ?

No, I'm saying that requiring a buffer_head to be able to do IO
is insanity. That's how things used to be in the pre-2001 days.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

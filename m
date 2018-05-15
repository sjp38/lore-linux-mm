Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 269036B0299
	for <linux-mm@kvack.org>; Tue, 15 May 2018 09:47:35 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id b83-v6so293657wme.7
        for <linux-mm@kvack.org>; Tue, 15 May 2018 06:47:35 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s20-v6si331630edd.412.2018.05.15.06.47.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 15 May 2018 06:47:33 -0700 (PDT)
Subject: Re: [PATCH 31/33] iomap: add support for sub-pagesize buffered I/O
 without buffer heads
References: <20180509074830.16196-1-hch@lst.de>
 <20180509074830.16196-32-hch@lst.de>
 <eebcc4bf-f646-edc6-264b-124b3880f3cb@suse.de>
 <20180515072625.GA23384@lst.de>
From: Goldwyn Rodrigues <rgoldwyn@suse.de>
Message-ID: <8b36b6c2-03b0-ea66-9bea-df2695dd1dba@suse.de>
Date: Tue, 15 May 2018 08:47:25 -0500
MIME-Version: 1.0
In-Reply-To: <20180515072625.GA23384@lst.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org



On 05/15/2018 02:26 AM, Christoph Hellwig wrote:
> On Mon, May 14, 2018 at 11:00:08AM -0500, Goldwyn Rodrigues wrote:
>>> +	if (iop || i_blocksize(inode) == PAGE_SIZE)
>>> +		return iop;
>>
>> Why is this an equal comparison operator? Shouldn't this be >= to
>> include filesystem blocksize greater than PAGE_SIZE?
> 
> Which filesystems would that be that have a tested and working PAGE_SIZE
> support using iomap?

Oh, I assumed iomap would work for filesystems with block size greater
than PAGE_SIZE.

-- 
Goldwyn

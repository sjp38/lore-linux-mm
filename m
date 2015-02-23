Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f173.google.com (mail-we0-f173.google.com [74.125.82.173])
	by kanga.kvack.org (Postfix) with ESMTP id 1D8A16B0032
	for <linux-mm@kvack.org>; Mon, 23 Feb 2015 12:57:49 -0500 (EST)
Received: by wesw55 with SMTP id w55so20398522wes.4
        for <linux-mm@kvack.org>; Mon, 23 Feb 2015 09:57:48 -0800 (PST)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id it4si19086856wid.13.2015.02.23.09.57.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 23 Feb 2015 09:57:47 -0800 (PST)
Date: Mon, 23 Feb 2015 18:57:44 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH] mm: shmem: check for mapping owner before dereferencing
Message-ID: <20150223175744.GA25919@lst.de>
References: <1424687880-8916-1-git-send-email-sasha.levin@oracle.com> <20150223174912.GA25675@lst.de> <54EB6950.6030909@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54EB6950.6030909@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>
Cc: Christoph Hellwig <hch@lst.de>, Sasha Levin <sasha.levin@oracle.com>, hughd@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, tj@kernel.org, jack@suse.cz

On Mon, Feb 23, 2015 at 09:54:24AM -0800, Jens Axboe wrote:
> On 02/23/2015 09:49 AM, Christoph Hellwig wrote:
>> Looks good,
>>
>> Reviewed-by: Christoph Hellwig <hch@lst.de>
>
> Shall I funnel this through for-linus?

Sounds fine to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

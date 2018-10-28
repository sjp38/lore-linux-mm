Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id BB6E06B034B
	for <linux-mm@kvack.org>; Sun, 28 Oct 2018 07:05:47 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id c6-v6so3851930pls.15
        for <linux-mm@kvack.org>; Sun, 28 Oct 2018 04:05:47 -0700 (PDT)
Received: from sonic301-21.consmr.mail.gq1.yahoo.com (sonic301-21.consmr.mail.gq1.yahoo.com. [98.137.64.147])
        by mx.google.com with ESMTPS id o1-v6si15931411pld.218.2018.10.28.04.05.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 28 Oct 2018 04:05:46 -0700 (PDT)
Subject: Re: [PATCH] mm: simplify get_next_ra_size
References: <1540707206-19649-1-git-send-email-hsiangkao@aol.com>
 <20181028102346.GC25444@bombadil.infradead.org>
From: Gao Xiang <hsiangkao@aol.com>
Message-ID: <ceee59a6-b691-8d80-c62b-1b51377d6153@aol.com>
Date: Sun, 28 Oct 2018 19:05:39 +0800
MIME-Version: 1.0
In-Reply-To: <20181028102346.GC25444@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Fengguang Wu <fengguang.wu@intel.com>

Hi Matthew,

On 2018/10/28 18:23, Matthew Wilcox wrote:
> On Sun, Oct 28, 2018 at 02:13:26PM +0800, Gao Xiang wrote:
>> It's a trivial simplification for get_next_ra_size and
>> clear enough for humans to understand.
>>
>> It also fixes potential overflow if ra->size(< ra_pages) is too large.
>>
>> Cc: Fengguang Wu <fengguang.wu@intel.com>
>> Signed-off-by: Gao Xiang <hsiangkao@aol.com>
> 
> Reviewed-by: Matthew Wilcox <willy@infradead.org>
> 
> I also considered what would happen with underflow (passing a 'max'
> less than 16, or less than 2) and it would seem to do the right thing
> in that case.

Yeah, thanks for the review ;)

I also made a simple tester to test this in order to ensure its correctness
and the result shows the same behavior except for the overflowed case.

Thanks,
Gao Xiang

> 

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f180.google.com (mail-we0-f180.google.com [74.125.82.180])
	by kanga.kvack.org (Postfix) with ESMTP id 3C32A6B0035
	for <linux-mm@kvack.org>; Thu,  2 Jan 2014 22:22:09 -0500 (EST)
Received: by mail-we0-f180.google.com with SMTP id t61so13039979wes.39
        for <linux-mm@kvack.org>; Thu, 02 Jan 2014 19:22:08 -0800 (PST)
Received: from mail-wg0-x234.google.com (mail-wg0-x234.google.com [2a00:1450:400c:c00::234])
        by mx.google.com with ESMTPS id pl12si163230wic.2.2014.01.02.19.22.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 02 Jan 2014 19:22:08 -0800 (PST)
Received: by mail-wg0-f52.google.com with SMTP id x13so13189297wgg.7
        for <linux-mm@kvack.org>; Thu, 02 Jan 2014 19:22:08 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20140102155726.GA865@suse.de>
References: <1388661922-10957-1-git-send-email-sj38.park@gmail.com> <20140102155726.GA865@suse.de>
From: SeongJae Park <sj38.park@gmail.com>
Date: Fri, 3 Jan 2014 12:21:47 +0900
Message-ID: <CAEjAshoYE=c_bfOAuR+0eP0No6PErFvSm9dDmrZ=RnXQPWW9fQ@mail.gmail.com>
Subject: Re: [PATCH] mm: page_alloc: use enum instead of number for migratetype
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Jan 3, 2014 at 12:57 AM, Mel Gorman <mgorman@suse.de> wrote:
> On Thu, Jan 02, 2014 at 08:25:22PM +0900, SeongJae Park wrote:
>> Using enum instead of number for migratetype everywhere would be better
>> for reading and understanding.
>>
>> Signed-off-by: SeongJae Park <sj38.park@gmail.com>
>
> This implicitly makes assumptions about the value of MIGRATE_UNMOVABLE
> and does not appear to actually fix or improve anything.
>
> --
> Mel Gorman
> SUSE Labs

I thought the implicit assumptions may be helpful for some kind of
people's readability.
But, anyway, I agree and respect your opinion now.

Thanks and Regards.
SeongJae Park

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

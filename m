Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f172.google.com (mail-yk0-f172.google.com [209.85.160.172])
	by kanga.kvack.org (Postfix) with ESMTP id E906B6B0036
	for <linux-mm@kvack.org>; Mon,  7 Jul 2014 18:50:18 -0400 (EDT)
Received: by mail-yk0-f172.google.com with SMTP id 142so1977092ykq.17
        for <linux-mm@kvack.org>; Mon, 07 Jul 2014 15:50:18 -0700 (PDT)
Received: from mail.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id n12si48600322yhh.165.2014.07.07.15.50.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Jul 2014 15:50:17 -0700 (PDT)
Message-ID: <53BB240C.30400@zytor.com>
Date: Mon, 07 Jul 2014 15:49:48 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: fallout of 16K stacks
References: <20140707223001.GD18735@two.firstfloor.org>
In-Reply-To: <20140707223001.GD18735@two.firstfloor.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>, torvalds@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 07/07/2014 03:30 PM, Andi Kleen wrote:
> 
> Since the 16K stack change I noticed a number of problems with
> my usual stress tests. They have a tendency to bomb out
> because something cannot fork.

As in ENOMEM or does something worse happen?

> - AIM7 on a dual socket socket system now cannot reliably run 
>> 1000 parallel jobs.

... with how much RAM?

> - LTP stress + memhog stress in parallel to something else
> usually doesn't survive the night.
> 
> Do we need to strengthen the memory allocator to try
> harder for 16K?

Can we even?  The probability of success goes down exponentially in the
order requested.  Movable pages can help, of course, but still, there is
a very real cost to this :(

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

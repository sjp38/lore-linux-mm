Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id F1B9D6B008A
	for <linux-mm@kvack.org>; Wed, 13 Nov 2013 18:10:31 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id hz1so1158561pad.3
        for <linux-mm@kvack.org>; Wed, 13 Nov 2013 15:10:31 -0800 (PST)
Received: from psmtp.com ([74.125.245.198])
        by mx.google.com with SMTP id sn7si4640697pab.283.2013.11.13.15.10.29
        for <linux-mm@kvack.org>;
        Wed, 13 Nov 2013 15:10:30 -0800 (PST)
Message-ID: <528406DB.7070605@ti.com>
Date: Wed, 13 Nov 2013 18:10:19 -0500
From: Santosh Shilimkar <santosh.shilimkar@ti.com>
MIME-Version: 1.0
Subject: Re: [PATCH 04/24] mm/block: remove unnecessary inclusion of bootmem.h
References: <1383954120-24368-1-git-send-email-santosh.shilimkar@ti.com> <1383954120-24368-5-git-send-email-santosh.shilimkar@ti.com> <20131113020918.GA25143@kernel.dk>
In-Reply-To: <20131113020918.GA25143@kernel.dk>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: tj@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, Grygorii Strashko <grygorii.strashko@ti.com>, Yinghai Lu <yinghai@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Tuesday 12 November 2013 09:09 PM, Jens Axboe wrote:
> On Fri, Nov 08 2013, Santosh Shilimkar wrote:
>> From: Grygorii Strashko <grygorii.strashko@ti.com>
>>
>> Clean-up to remove depedency with bootmem headers.
> 
> Thanks, cleaned up for after merge window inclusion. Changed the wording
> to make it more correct and fixed the spelling error:
> 
> block: cleanup removing dependency on bootmem headers
> 
Thanks !!

regards,
Santosh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

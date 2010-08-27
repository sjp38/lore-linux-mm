Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 58A3C6B01FA
	for <linux-mm@kvack.org>; Fri, 27 Aug 2010 05:38:11 -0400 (EDT)
Message-ID: <4C778623.6000303@kernel.org>
Date: Fri, 27 Aug 2010 11:32:19 +0200
From: Tejun Heo <tj@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH] percpu: fix a memory leak in pcpu_extend_area_map()
References: <1281261197-8816-1-git-send-email-shijie8@gmail.com>	<4C5EA651.7080009@kernel.org> <20100826151017.63b20d2e.akpm@linux-foundation.org>
In-Reply-To: <20100826151017.63b20d2e.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Huang Shijie <shijie8@gmail.com>, linux-mm@kvack.org, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hello,

On 08/27/2010 12:10 AM, Andrew Morton wrote:
>> Patch applied to percpu#for-linus w/ some updates.  Thanks a lot for
>> catching this.
> 
> This patch appears to have been lost?

It has been in percpu#for-linus.  Given the way percpu allocator is
currently used, the bug isn't likely to cause any real leakage, so I
was waiting a bit before pushing it out.  I'll push it today.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

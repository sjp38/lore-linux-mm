Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 949296B0038
	for <linux-mm@kvack.org>; Thu, 21 Dec 2017 20:51:05 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id v190so16712247pgv.11
        for <linux-mm@kvack.org>; Thu, 21 Dec 2017 17:51:05 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id c25si5504983pgn.16.2017.12.21.17.51.03
        for <linux-mm@kvack.org>;
        Thu, 21 Dec 2017 17:51:04 -0800 (PST)
Date: Fri, 22 Dec 2017 10:51:15 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 00/18] introduce a new tool, valid access checker
Message-ID: <20171222015114.GC1729@js1304-P5Q-DELUXE>
References: <1511855333-3570-1-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1511855333-3570-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Namhyung Kim <namhyung@kernel.org>, Wengang Wang <wen.gang.wang@oracle.com>

On Tue, Nov 28, 2017 at 04:48:35PM +0900, js1304@gmail.com wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> Hello,
> 
> This patchset introduces a new tool, valid access checker.
> 
> Vchecker is a dynamic memory error detector. It provides a new debug feature
> that can find out an un-intended access to valid area. Valid area here means
> the memory which is allocated and allowed to be accessed by memory owner and
> un-intended access means the read/write that is initiated by non-owner.
> Usual problem of this class is memory overwritten.
> 
> Most of debug feature focused on finding out un-intended access to
> in-valid area, for example, out-of-bound access and use-after-free, and,
> there are many good tools for it. But, as far as I know, there is no good tool
> to find out un-intended access to valid area. This kind of problem is really
> hard to solve so this tool would be very useful.
> 
> This tool doesn't automatically catch a problem. Manual runtime configuration
> to specify the target object is required.
> 
> Note that there was a similar attempt for the debugging overwritten problem
> however it requires manual code modifying and recompile.
> 
> http://lkml.kernel.org/r/<20171117223043.7277-1-wen.gang.wang@oracle.com>
> 
> To get more information about vchecker, please see a documention at
> the last patch.
> 
> Patchset can also be available at
> 
> https://github.com/JoonsooKim/linux/tree/vchecker-master-v1.0-next-20171122
> 
> Enjoy it.
> 
> Thanks.

Hello, Andrew.

Before the fixing some build failure on this patchset, I'd like to know
other reviewer's opinion on this patchset, especially, yours. :)

There are some interests on this patchset from some developers. Wengang
come up with a very similar change and Andi said that this looks useful.
Do you think that this tool is useful and can be merged?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

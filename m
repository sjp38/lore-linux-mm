Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4A5FF6B0253
	for <linux-mm@kvack.org>; Thu, 18 Jan 2018 17:39:40 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id y13so16625627wrb.17
        for <linux-mm@kvack.org>; Thu, 18 Jan 2018 14:39:40 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id a5si6843655wrh.61.2018.01.18.14.39.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jan 2018 14:39:38 -0800 (PST)
Date: Thu, 18 Jan 2018 14:39:35 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 00/18] introduce a new tool, valid access checker
Message-Id: <20180118143935.6d782b3ecaba5186dea4eecd@linux-foundation.org>
In-Reply-To: <20171222015114.GC1729@js1304-P5Q-DELUXE>
References: <1511855333-3570-1-git-send-email-iamjoonsoo.kim@lge.com>
	<20171222015114.GC1729@js1304-P5Q-DELUXE>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Namhyung Kim <namhyung@kernel.org>, Wengang Wang <wen.gang.wang@oracle.com>

On Fri, 22 Dec 2017 10:51:15 +0900 Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:

> On Tue, Nov 28, 2017 at 04:48:35PM +0900, js1304@gmail.com wrote:
> > From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > 
> > Hello,
> > 
> > This patchset introduces a new tool, valid access checker.
> > 
> > Vchecker is a dynamic memory error detector. It provides a new debug feature
> > that can find out an un-intended access to valid area. Valid area here means
> > the memory which is allocated and allowed to be accessed by memory owner and
> > un-intended access means the read/write that is initiated by non-owner.
> > Usual problem of this class is memory overwritten.
> > 
> > Most of debug feature focused on finding out un-intended access to
> > in-valid area, for example, out-of-bound access and use-after-free, and,
> > there are many good tools for it. But, as far as I know, there is no good tool
> > to find out un-intended access to valid area. This kind of problem is really
> > hard to solve so this tool would be very useful.
> > 
> > This tool doesn't automatically catch a problem. Manual runtime configuration
> > to specify the target object is required.
> > 
> > Note that there was a similar attempt for the debugging overwritten problem
> > however it requires manual code modifying and recompile.
> > 
> > http://lkml.kernel.org/r/<20171117223043.7277-1-wen.gang.wang@oracle.com>
> > 
> > To get more information about vchecker, please see a documention at
> > the last patch.
> > 
> > Patchset can also be available at
> > 
> > https://github.com/JoonsooKim/linux/tree/vchecker-master-v1.0-next-20171122
> > 
> > Enjoy it.
> > 
> > Thanks.
> 
> Hello, Andrew.
> 
> Before the fixing some build failure on this patchset, I'd like to know
> other reviewer's opinion on this patchset, especially, yours. :)
> 
> There are some interests on this patchset from some developers. Wengang
> come up with a very similar change and Andi said that this looks useful.
> Do you think that this tool is useful and can be merged?
> 

My main fear is that the feature will sit there and nobody will use it.

Are there ways around that?  For example, can we arrange with the test
robot(s) to get vchecker operating on their setups in some automatable
fashion and have them checking for bugs?

Any other suggestions as to how we could get this feature to be used by
others and producing useful results?

And has vchecker actually found any real bugs in existing code?  If so,
a description of that would be illuminating.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

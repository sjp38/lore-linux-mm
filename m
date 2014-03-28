Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f173.google.com (mail-vc0-f173.google.com [209.85.220.173])
	by kanga.kvack.org (Postfix) with ESMTP id 6E9866B0035
	for <linux-mm@kvack.org>; Fri, 28 Mar 2014 13:08:49 -0400 (EDT)
Received: by mail-vc0-f173.google.com with SMTP id il7so6083347vcb.18
        for <linux-mm@kvack.org>; Fri, 28 Mar 2014 10:08:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140328145826.GE29656@kvack.org>
References: <20140327134653.GA22407@kvack.org>
	<CA+55aFzFgY4-26SO-MsFagzaj9JevkeeT1OJ3pjj-tcjuNCEeQ@mail.gmail.com>
	<CA+55aFx7vg2rvOu6Bu_e8+BB=ymoUMp0AM9JmAuUuSgo0LVEwg@mail.gmail.com>
	<20140327200851.GL17679@kvack.org>
	<CA+55aFy_sRnFu7KguAUAN5kbHk3Qa_0ZuATPU5i8LOyMMWZ_5g@mail.gmail.com>
	<20140327205749.GM17679@kvack.org>
	<CA+55aFyj2XFMkT1T=EPPw1CANt6atyFNmMaeaDm-p-NWfRNA+w@mail.gmail.com>
	<20140328145826.GE29656@kvack.org>
Date: Fri, 28 Mar 2014 10:08:47 -0700
Message-ID: <CA+55aFyye6K4ifJ778uZ_pNFKa7=R0KsKREmJkimEQxW3nDhDA@mail.gmail.com>
Subject: Re: git pull -- [PATCH] aio: v2 ensure access to ctx->ring_pages is
 correctly serialised
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin LaHaise <bcrl@kvack.org>
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Sasha Levin <sasha.levin@oracle.com>, Tang Chen <tangchen@cn.fujitsu.com>, Gu Zheng <guz.fnst@cn.fujitsu.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, stable <stable@vger.kernel.org>, linux-aio@kvack.org, linux-mm <linux-mm@kvack.org>

On Fri, Mar 28, 2014 at 7:58 AM, Benjamin LaHaise <bcrl@kvack.org> wrote:
>
> Here's a respin of that part.  I just moved the mutex initialization up so
> that it's always valid in the err path.  I have also run this version of
> the patch through xfstests and my migration test programs and it looks
> okay.

Ok. I can't find any issues with this version. How critical is this?
Should I take it now, or with more testing during the 3.15 merge
window and then just have it picked up from stable? Do people actually
trigger the bug in real life, or has this been more of a
trinity/source code analysis thing?

                Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

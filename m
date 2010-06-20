Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 70FDA6B0071
	for <linux-mm@kvack.org>; Sun, 20 Jun 2010 02:19:57 -0400 (EDT)
Received: by bwz4 with SMTP id 4so847951bwz.14
        for <linux-mm@kvack.org>; Sat, 19 Jun 2010 23:19:55 -0700 (PDT)
MIME-Version: 1.0
Reply-To: mtk.manpages@gmail.com
In-Reply-To: <20100619195242.GS18946@basil.fritz.box>
References: <200912081016.198135742@firstfloor.org> <20091208211647.9B032B151F@basil.firstfloor.org>
	<AANLkTimBhQAYn7BDXd1ykSN90v0ClWybIe2Pe1qv_6vA@mail.gmail.com>
	<20100619132055.GK18946@basil.fritz.box> <AANLkTin-lj5ZgtcvJhWcNiMuWSCQ39N8mqe_2fm8DDVR@mail.gmail.com>
	<20100619133000.GL18946@basil.fritz.box> <AANLkTiloIXtCwBeBvP32hLBBvxCWrZMMwWTZwSj475wi@mail.gmail.com>
	<20100619140933.GM18946@basil.fritz.box> <AANLkTilF6m5YKMiDGaTNuoW6LxiA44oss3HyvkavwrOK@mail.gmail.com>
	<20100619195242.GS18946@basil.fritz.box>
From: Michael Kerrisk <mtk.manpages@gmail.com>
Date: Sun, 20 Jun 2010 08:19:35 +0200
Message-ID: <AANLkTikMZu0GXwzs6IeMyoTuhETrnjZ1m5lI9FTauYBA@mail.gmail.com>
Subject: Re: [PATCH] [31/31] HWPOISON: Add a madvise() injector for soft page
	offlining
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: fengguang.wu@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Andi,
On Sat, Jun 19, 2010 at 9:52 PM, Andi Kleen <andi@firstfloor.org> wrote:
>> .TP
>> .BR MADV_SOFT_OFFLINE " (Since Linux 2.6.33)
>> Soft offline the pages in the range specified by
>> .I addr
>> and
>> .IR length .
>> This memory of each page in the specified range is copied to a new page,
>
> Actually there are some cases where it's also dropped if it's cached page.
>
> Perhaps better would be something more fuzzy like
>
> "the contents are preserved"

The problem to me is that this gets so fuzzy that it's hard to
understand the meaning (I imagine many readers will ask: "What does it
mean that the contents are preserved"?). Would you be able to come up
with a wording that is a little miore detailed?

>> and the original page is offlined
>> (i.e., no longer used, and taken out of normal memory management).

Thanks,

Michael


-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Author of "The Linux Programming Interface" http://blog.man7.org/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

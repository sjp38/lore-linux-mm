Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 3FBA26B01C7
	for <linux-mm@kvack.org>; Sat, 19 Jun 2010 10:17:46 -0400 (EDT)
Received: by ewy21 with SMTP id 21so102427ewy.14
        for <linux-mm@kvack.org>; Sat, 19 Jun 2010 07:17:44 -0700 (PDT)
MIME-Version: 1.0
Reply-To: mtk.manpages@gmail.com
In-Reply-To: <20100619140933.GM18946@basil.fritz.box>
References: <200912081016.198135742@firstfloor.org> <20091208211647.9B032B151F@basil.firstfloor.org>
	<AANLkTimBhQAYn7BDXd1ykSN90v0ClWybIe2Pe1qv_6vA@mail.gmail.com>
	<20100619132055.GK18946@basil.fritz.box> <AANLkTin-lj5ZgtcvJhWcNiMuWSCQ39N8mqe_2fm8DDVR@mail.gmail.com>
	<20100619133000.GL18946@basil.fritz.box> <AANLkTiloIXtCwBeBvP32hLBBvxCWrZMMwWTZwSj475wi@mail.gmail.com>
	<20100619140933.GM18946@basil.fritz.box>
From: Michael Kerrisk <mtk.manpages@gmail.com>
Date: Sat, 19 Jun 2010 16:17:24 +0200
Message-ID: <AANLkTilF6m5YKMiDGaTNuoW6LxiA44oss3HyvkavwrOK@mail.gmail.com>
Subject: Re: [PATCH] [31/31] HWPOISON: Add a madvise() injector for soft page
	offlining
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: fengguang.wu@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Andi,

On Sat, Jun 19, 2010 at 4:09 PM, Andi Kleen <andi@firstfloor.org> wrote:
> On Sat, Jun 19, 2010 at 03:43:28PM +0200, Michael Kerrisk wrote:
>> Is there a userspace operation to unpoison (i.e., reverse MADV_SOFT_OFFLINE)?
>
> Yes, but it's only a debugfs interface currently.

Okay -- thanks.

>> I ask because I wondered if there is something additional to be documented.
>
> I don't think debugfs needs manpages atm.

Okay.

I edited your text somewhat. Could you please review the below.

Cheers,

Michael

.TP
.BR MADV_SOFT_OFFLINE " (Since Linux 2.6.33)
Soft offline the pages in the range specified by
.I addr
and
.IR length .
This memory of each page in the specified range is copied to a new page,
and the original page is offlined
(i.e., no longer used, and taken out of normal memory management).
The effect of the
.B MADV_SOFT_OFFLINE
operation is normally invisible to (i.e., does not change the semantics of)
the calling process.
This feature is intended for testing of memory error-handling code;
it is only available if the kernel was configured with
.BR CONFIG_MEMORY_FAILURE .

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

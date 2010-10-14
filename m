Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 413E56B017A
	for <linux-mm@kvack.org>; Thu, 14 Oct 2010 17:50:52 -0400 (EDT)
Received: by bwz19 with SMTP id 19so1084563bwz.14
        for <linux-mm@kvack.org>; Thu, 14 Oct 2010 14:50:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20101015001904I.fujita.tomonori@lab.ntt.co.jp>
References: <87sk0a1sq0.fsf@basil.nowhere.org>
	<20101014160217N.fujita.tomonori@lab.ntt.co.jp>
	<AANLkTin-8mjL_B8g9cPoviQU0FUaEyb_v5_Fm4kbSweA@mail.gmail.com>
	<20101015001904I.fujita.tomonori@lab.ntt.co.jp>
Date: Fri, 15 Oct 2010 00:50:49 +0300
Message-ID: <AANLkTik7Gj0M64D8kYoToja3QmmSLMCUQHjVPKibp0Qm@mail.gmail.com>
Subject: Re: [RFC][PATCH 1/3] contigous big page allocator
From: Felipe Contreras <felipe.contreras@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Cc: andi@firstfloor.org, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

On Thu, Oct 14, 2010 at 6:24 PM, FUJITA Tomonori
<fujita.tomonori@lab.ntt.co.jp> wrote:
> On Thu, 14 Oct 2010 15:09:13 +0300
> Felipe Contreras <felipe.contreras@gmail.com> wrote:
>
>> > As already pointed out, some embeded drivers need physcailly
>> > contignous memory. Currenlty, they use hacky tricks (e.g. playing with
>> > the boot memory allocators). There are several proposals for this like
>> > adding a new kernel memory allocator (from samsung).
>> >
>> > It's ideal if the memory allocator can handle this, I think.
>>
>> Not only contiguous, but sometimes also coherent.
>
> Can you give the list of such drivers?

omapfb and tidspbridge. Perhaps tidspbridge can be modified to flush
the relevant memory, but for now it does. I'm not sure about omapfb,
but it would be very likely that user-space would need to be modified
if flushes suddenly become required.

-- 
Felipe Contreras

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

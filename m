Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 6299D6B0200
	for <linux-mm@kvack.org>; Tue, 11 May 2010 13:54:14 -0400 (EDT)
Received: by pwi10 with SMTP id 10so2338539pwi.14
        for <linux-mm@kvack.org>; Tue, 11 May 2010 10:54:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1273553765.21352.1.camel@pasglop>
References: <1273484339-28911-1-git-send-email-benh@kernel.crashing.org>
	 <1273484339-28911-14-git-send-email-benh@kernel.crashing.org>
	 <1273484339-28911-15-git-send-email-benh@kernel.crashing.org>
	 <1273484339-28911-16-git-send-email-benh@kernel.crashing.org>
	 <1273484339-28911-17-git-send-email-benh@kernel.crashing.org>
	 <1273484339-28911-18-git-send-email-benh@kernel.crashing.org>
	 <1273484339-28911-19-git-send-email-benh@kernel.crashing.org>
	 <1273484339-28911-20-git-send-email-benh@kernel.crashing.org>
	 <AANLkTinOVSpCXdkkcCHMdN-HWsImE7_Gcbgg5plnNMss@mail.gmail.com>
	 <1273553765.21352.1.camel@pasglop>
Date: Tue, 11 May 2010 10:54:11 -0700
Message-ID: <AANLkTilUCwtBfi2xHIN1bQAcY1irmpOb6Hn0tyJeYOuV@mail.gmail.com>
Subject: Re: [PATCH 19/25] lmb: Add array resizing support
From: Yinghai Lu <yinghai@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, tglx@linuxtronix.de, mingo@elte.hu, davem@davemloft.net, lethal@linux-sh.org
List-ID: <linux-mm.kvack.org>

On Mon, May 10, 2010 at 9:56 PM, Benjamin Herrenschmidt
<benh@kernel.crashing.org> wrote:
> On Mon, 2010-05-10 at 16:59 -0700, Yinghai Lu wrote:
>> you need to pass base, base+size with lmb_double_array()
>>
>> otherwise when you are using lmb_reserve(base, size), double_array()
>> array could have chance to get
>> new buffer that is overlapped with [base, base + size).
>>
>> to keep it simple, should check_double_array() after lmb_reserve,
>> lmb_add, lmb_free (yes, that need it too).
>> that was suggested by Michael Ellerman.
>>
>
> No. You may notice that I addressed this problem by moving the
> call to lmb_double_array() to -after- we record the entry in
> the array, so it shouldn't be able to pickup the same one.

oh, you are right.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

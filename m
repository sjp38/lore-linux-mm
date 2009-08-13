Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 54FF76B004F
	for <linux-mm@kvack.org>; Thu, 13 Aug 2009 13:31:52 -0400 (EDT)
Received: by ywh32 with SMTP id 32so1229266ywh.11
        for <linux-mm@kvack.org>; Thu, 13 Aug 2009 10:31:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <200908130805.36787.a1426z@gawab.com>
References: <200908122007.43522.ngupta@vflare.org>
	 <Pine.LNX.4.64.0908122312380.25501@sister.anvils>
	 <4A837D5A.3070407@vflare.org> <200908130805.36787.a1426z@gawab.com>
Date: Thu, 13 Aug 2009 23:01:49 +0530
Message-ID: <d760cf2d0908131031i2305f2deqe20d6a96c8d568af@mail.gmail.com>
Subject: Re: compcache as a pre-swap area (was: [PATCH] swap: send callback
	when swap slot is freed)
From: Nitin Gupta <ngupta@vflare.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Al Boldi <a1426z@gawab.com>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, Matthew Wilcox <willy@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 13, 2009 at 10:35 AM, Al Boldi<a1426z@gawab.com> wrote:
> Nitin Gupta wrote:
>> BTW, last time compcache was not accepted due to lack of performance
>> numbers. Now the project has lot more data for various cases:
>> http://code.google.com/p/compcache/wiki/Performance
>> Still need to collect data for worst-case behaviors and such...
>
> I checked the link, and it looks like you are positioning compcache as a =
swap
> replacement. =A0If so, then repositioning it as a compressed pre-swap are=
a
> working together with normal swap-space, if available, may yield a much m=
ore
> powerful system.
>
>

compcache is really not really a swap replacement. Its just another
swap device that
compresses data and stores it in memory itself. You can have disk
based swaps along
with ramzswap (name of block device).

Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

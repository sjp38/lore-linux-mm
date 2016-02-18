Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 07AF16B025E
	for <linux-mm@kvack.org>; Thu, 18 Feb 2016 07:38:37 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id g62so23271594wme.0
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 04:38:36 -0800 (PST)
Received: from mail-wm0-x234.google.com (mail-wm0-x234.google.com. [2a00:1450:400c:c09::234])
        by mx.google.com with ESMTPS id q200si4904329wmg.67.2016.02.18.04.38.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Feb 2016 04:38:36 -0800 (PST)
Received: by mail-wm0-x234.google.com with SMTP id g62so23413512wme.0
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 04:38:35 -0800 (PST)
MIME-Version: 1.0
Reply-To: mtk.manpages@gmail.com
In-Reply-To: <20160217174654.GA3505386@devbig084.prn1.facebook.com>
References: <d01698140a51cf9b2ce233c7574c2ece9f6fa241.1449791762.git.shli@fb.com>
 <20160216160802.50ceaf10aa16588e18b3d2c5@linux-foundation.org> <20160217174654.GA3505386@devbig084.prn1.facebook.com>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Date: Thu, 18 Feb 2016 13:38:16 +0100
Message-ID: <CAKgNAkhBp8FmqRKe4a5fzmqOgSE7sTEJd95WPg0L5W-uCuAv6Q@mail.gmail.com>
Subject: Re: [PATCH V4][for-next]mm: add a new vector based madvise syscall
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>, Kernel-team@fb.com, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Minchan Kim <minchan@kernel.org>, Arnd Bergmann <arnd@arndb.de>, Jason Evans <je@fb.com>

Hello Shaohua Li,

On 17 February 2016 at 18:47, Shaohua Li <shli@fb.com> wrote:
> On Tue, Feb 16, 2016 at 04:08:02PM -0800, Andrew Morton wrote:
>> On Thu, 10 Dec 2015 16:03:37 -0800 Shaohua Li <shli@fb.com> wrote:

[...]

>> It would be good for us to have a look at the manpage before going too
>> far with the patch - this helps reviewers to think about the proposed
>> interface and behaviour.
>>
>> I'll queue this up for a bit of testing, although it won't get tested
>> much.  The syscall fuzzers will presumably hit on it.

Please don't forget the other piece. A patch, or a suitable piece of
text for the madvise.2 man page please!

Cheers,

Michael


-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

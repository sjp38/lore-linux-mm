Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 523166B0071
	for <linux-mm@kvack.org>; Mon, 22 Oct 2012 12:42:43 -0400 (EDT)
Received: by mail-ia0-f169.google.com with SMTP id h37so2802679iak.14
        for <linux-mm@kvack.org>; Mon, 22 Oct 2012 09:42:42 -0700 (PDT)
MIME-Version: 1.0
Reply-To: mtk.manpages@gmail.com
In-Reply-To: <20121022162929.GN2095@tassilo.jf.intel.com>
References: <1350665289-7288-1-git-send-email-andi@firstfloor.org>
 <CAHO5Pa0W-WGBaPvzdRJxYPdrg-K9guChswo3KJheK4BaRzsRwQ@mail.gmail.com>
 <20121022132733.GQ16230@one.firstfloor.org> <20121022133534.GR16230@one.firstfloor.org>
 <CAKgNAkgQ6JZdwOsCAQ4Ak_gVXtav=TzgzW2tbk5jMUwxtMqOAg@mail.gmail.com>
 <20121022153633.GK2095@tassilo.jf.intel.com> <CAKgNAki=AL+KdYDdYnE8ZhjK-tUf5cZ163BWPe6GRM0rpi-z7w@mail.gmail.com>
 <20121022161151.GS16230@one.firstfloor.org> <CAKgNAkjsGp9HUpvhUfqbXnfrLbBsQRAKvOs=41-w3ZAE7yX+cA@mail.gmail.com>
 <20121022162929.GN2095@tassilo.jf.intel.com>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Date: Mon, 22 Oct 2012 18:42:22 +0200
Message-ID: <CAKgNAkhn+kTAq6_VKB3GjwwZGD-YOKE67=4fp+SR=1Lbhz7Bxg@mail.gmail.com>
Subject: Re: [PATCH] MM: Support more pagesizes for MAP_HUGETLB/SHM_HUGETLB v6
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <ak@linux.intel.com>
Cc: Andi Kleen <andi@firstfloor.org>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hillf Danton <dhillf@gmail.com>

On Mon, Oct 22, 2012 at 6:29 PM, Andi Kleen <ak@linux.intel.com> wrote:
>> Since PowerPC already allows 16GB page sizes, doesn't there need to be
>> allowance for the possibility of future expansion? Choosing a larger
>> minimum size (like 2^16) would allow that. Does the minimum size need
>> to be 16k? (Surely, if you want a HUGEPAGE, you want a bigger page
>> than that? I am not sure.)
>
> Some architectures have configurable huge page sizes, so it depends on
> the user. I thought 16K is reasonable.  Can make it larger too.
>
> But I personally consider even 16GB pages somewhat too big.

I do not know the answer course ;-). Just thought that it was worth
emphasizing that some system already allows the upper limit you
propose. It seems inevitable that some other system will allow
something even bigger.

Anyway, I got distracted from my earlier more important point. This
proposed change will chew up most (all?) of the remaining bit-space in
'flags'. This seems like a mistake from a future extensibility point
of view... It sounds a lot like you'll force someone else to write and
deploy mmap3()...

-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Author of "The Linux Programming Interface"; http://man7.org/tlpi/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

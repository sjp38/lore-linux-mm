Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 347B26B0068
	for <linux-mm@kvack.org>; Thu, 22 Dec 2011 10:52:42 -0500 (EST)
Received: by iacb35 with SMTP id b35so15491804iac.14
        for <linux-mm@kvack.org>; Thu, 22 Dec 2011 07:52:41 -0800 (PST)
Message-ID: <4EF35243.9030600@gmail.com>
Date: Thu, 22 Dec 2011 23:52:35 +0800
From: "nai.xia" <nai.xia@gmail.com>
MIME-Version: 1.0
Subject: Re: Question about missing "cld" in x86 string assembly code
References: <201112172258.24221.nai.xia@gmail.com> <CAMzpN2inHxaSnaYaYXZ4Ya3rK+MWXqR6dN5NVNZy3=OvP04uQA@mail.gmail.com> <CA+55aFzyEgDUSaNVQ1Nw5SBNd36Cvb-KrVdc1MYj+oRJt8xWgg@mail.gmail.com>
In-Reply-To: <CA+55aFzyEgDUSaNVQ1Nw5SBNd36Cvb-KrVdc1MYj+oRJt8xWgg@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Brian Gerst <brgerst@gmail.com>, Andi Kleen <ak@linux.intel.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>



On 2011a1'12ae??18ae?JPY 02:39, Linus Torvalds wrote:
> On Sat, Dec 17, 2011 at 9:08 AM, Brian Gerst<brgerst@gmail.com>  wrote:
>>
>> The i386 ELF ABI states "The direction flag must be set to the
>> a??a??forwarda??a?? (that is, zero) direction before entry and upon exit from
>> a function."  Therefore it can be assumed to be clear, unless
>> explicitly set.
>
> The exception, of course, being bootup, fault and interrupt handlers,
> and after we've called out to foreign code (ie BIOS).

Yeah, I think I see these cld's now. Thanks for the answers!


Nai
>
> So there *are* a few cld's sprinkled around, they are just fairly rare.
>
>                      Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 47E0E6B0044
	for <linux-mm@kvack.org>; Mon, 10 Dec 2012 17:15:57 -0500 (EST)
Date: Mon, 10 Dec 2012 23:15:50 +0100
From: Zlatko Calusic <zlatko.calusic@iskon.hr>
MIME-Version: 1.0
References: <alpine.LFD.2.02.1212081651270.4593@air.linux-foundation.org> <20121210110337.GH1009@suse.de> <20121210163904.GA22101@cmpxchg.org> <20121210180141.GK1009@suse.de> <50C62AE6.3030000@iskon.hr> <CA+55aFwNE2y5t2uP3esCnHsaNo0NTDnGvzN6KF0qTw_y+QbtFA@mail.gmail.com> <50C6477A.4090005@iskon.hr> <CA+55aFx9XSjtMZNuveyKrxL0LUjmZpFvJ7vzkjaKgQZLCs9QCg@mail.gmail.com> <20121210214256.GB23484@liondog.tnic> <CA+55aFzPa1tk_uWs_1cyYD0XpjWg_Fn+o431hUk3AnabOeUXSQ@mail.gmail.com> <20121210215436.GA31536@liondog.tnic>
In-Reply-To: <20121210215436.GA31536@liondog.tnic>
Message-ID: <50C65F16.1060809@iskon.hr>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Subject: Re: kswapd craziness in 3.7
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>

On 10.12.2012 22:54, Borislav Petkov wrote:
> On Mon, Dec 10, 2012 at 01:47:23PM -0800, Linus Torvalds wrote:
>> On Mon, Dec 10, 2012 at 1:42 PM, Borislav Petkov <bp@alien8.de> wrote:
>>>
>>> Aren't we gonna consider the out-of-tree vbox modules being loaded and
>>> causing some corruptions like maybe the single-bit error above?
>>>
>>> I'm also thinking of this here: https://lkml.org/lkml/2011/10/6/317
>>
>> Yup, that looks more likely, I agree.
>
> @Zlatko: can your daughter try to retrigger the freeze without the vbox
> modules loaded?
>

Sure thing! :)

Although, the vbox modules were only loaded, no VM was running at the 
time lockup happened. But, I've just read the whole thread you mention 
above and I understand the concern. I'll make sure the vbox modules are 
unloaded when not really needed (most of the time on that machine), in 
case lockup happens again.

Next time my daughter plays online games, I'll tell her she's actually 
serving a greater purpose, and let her take her time. :)
-- 
Zlatko

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

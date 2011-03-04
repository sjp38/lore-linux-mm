Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 70AF78D0039
	for <linux-mm@kvack.org>; Fri,  4 Mar 2011 17:54:26 -0500 (EST)
Message-ID: <4D716D9C.6060903@cesarb.net>
Date: Fri, 04 Mar 2011 19:54:20 -0300
From: Cesar Eduardo Barros <cesarb@cesarb.net>
MIME-Version: 1.0
Subject: Re: [PATCHv2 00/24] Refactor sys_swapon
References: <4D6D7FEA.80800@cesarb.net> <1299022128-6239-1-git-send-email-cesarb@cesarb.net> <20110303161550.GA4095@mgebm.net>
In-Reply-To: <20110303161550.GA4095@mgebm.net>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@mgebm.net>
Cc: linux-mm@kvack.org

Em 03-03-2011 13:15, Eric B Munson escreveu:
> On Tue, 01 Mar 2011, Cesar Eduardo Barros wrote:
>
>> This patch series refactors the sys_swapon function.
>>
>> sys_swapon is currently a very large function, with 313 lines (more than
>> 12 25-line screens), which can make it a bit hard to read. This patch
>> series reduces this size by half, by extracting large chunks of related
>> code to new helper functions.
>>
>> One of these chunks of code was nearly identical to the part of
>> sys_swapoff which is used in case of a failure return from
>> try_to_unuse(), so this patch series also makes both share the same
>> code.
>>
>> As a side effect of all this refactoring, the compiled code gets a bit
>> smaller (from v1 of this patch series):
>>
>>     text       data        bss        dec        hex    filename
>>    14012        944        276      15232       3b80    mm/swapfile.o.before
>>    13941        944        276      15161       3b39    mm/swapfile.o.after
>>
>> The v1 of this patch series was lightly tested on a x86_64 VM.
>
> One more small suggestion, you should cc LKML on this series, as well as any
> of the other emails suggested by get_maintainer.pl.

Should I resend the whole patch series with the correct Cc:?

-- 
Cesar Eduardo Barros
cesarb@cesarb.net
cesar.barros@gmail.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 0F5456B03A7
	for <linux-mm@kvack.org>; Mon, 23 Aug 2010 05:10:03 -0400 (EDT)
Received: by iwn33 with SMTP id 33so4197321iwn.14
        for <linux-mm@kvack.org>; Mon, 23 Aug 2010 02:10:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <C06122FE6B6044BD94C8A632B205D909@rainbow>
References: <20100817111018.GQ19797@csn.ul.ie>
	<4385155269B445AEAF27DC8639A953D7@rainbow>
	<20100818154130.GC9431@localhost>
	<565A4EE71DAC4B1A820B2748F56ABF73@rainbow>
	<20100819160006.GG6805@barrios-desktop>
	<AA3F2D89535A431DB91FE3032EDCB9EA@rainbow>
	<20100820053447.GA13406@localhost>
	<20100820093558.GG19797@csn.ul.ie>
	<AANLkTimVmoomDjGMCfKvNrS+v-mMnfeq6JDZzx7fjZi+@mail.gmail.com>
	<20100822153121.GA29389@barrios-desktop>
	<20100822232316.GA339@localhost>
	<AANLkTim8c5C+vH1HUx-GsScirmnVoJXenLST1qQgk2bp@mail.gmail.com>
	<C06122FE6B6044BD94C8A632B205D909@rainbow>
Date: Mon, 23 Aug 2010 18:10:02 +0900
Message-ID: <AANLkTikwZtaMioEOnwTJhs-PkXWeaZhv-hYXG13n=OBX@mail.gmail.com>
Subject: Re: compaction: trying to understand the code
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Iram Shahzad <iram.shahzad@jp.fujitsu.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, Aug 23, 2010 at 12:03 PM, Iram Shahzad
<iram.shahzad@jp.fujitsu.com> wrote:
>> Iram. How do you execute test_app?
>>
>> 1) synchronous test
>> 1.1 start test_app
>> 1.2 wait test_app job done (ie, wait memory is fragment)
>> 1.3 echo 1 > /proc/sys/vm/compact_memory
>>
>> 2) asynchronous test
>> 2.1 start test_app
>> 2.2 not wait test_app job done
>> 2.3 echo 1 > /proc/sys/vm/compact_memory(Maybe your test app and
>> compaction were executed parallel)
>
> It's synchronous.
> First I confirm that the test app has completed its fragmentation work
> by looking at the printf output. Then only I run echo 1 >
> /proc/sys/vm/compact_memory.
>
> After completing fragmentation work, my test app sleeps in a useless while
> loop
> which I think is not important.

Thanks. It seems to be not any other processes which is entering
direct reclaiming.
I tested your test_app but failed to reproduce your problem.
Actually I suspected some leak of decrease NR_ISOLATE_XXX but my
system worked well.
And I couldn't find the point as just code reviewing. If it really
was, Mel found it during his stress test.

Hmm.. Mystery.
Maybe we need some tracepoint to debug.
-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

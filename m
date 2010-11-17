Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4929F6B012C
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 11:58:52 -0500 (EST)
Message-ID: <4CE409C8.8010508@phoronix.com>
Date: Wed, 17 Nov 2010 08:58:48 -0800
From: Matthew Tippett <matthew@phoronix.com>
MIME-Version: 1.0
Subject: Re: [patch] mm: vmscan implement per-zone shrinkers
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: anca.emanuel@gmail.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>>
>>>>>  hi KOSAKI Motohiro,
>>>>>
>>>>>  is it any test suite or test scripts for test page-reclaim performance?
>>>>>
>>>>>  Best,
>>>>>  Figo.zhang
>>>>>
>>>>
>>>>  There ishttp://www.phoronix.com
>>>
>>>  it is not focus on page-reclaim test, or specially for MM.
>>>>
>>>
>>>
>>
>>  If you want some special test, you have to ask Michael Larabel for that.
>>  http://www.phoronix-test-suite.com/
>
>  yes, i see, the phoronix-test-suite is test such as ffmpeg, games. not
>  focus on MM.

Phoronix Test Suite is a framework for executing tests.  If there are particular
pre-existing tests or particular tests that you would like see available through
Phoronix Test Suite, then please advise.

Test Profiles are easy to add, so having a broad set of tests that measure the MM
subsystem would be useful general addition.

If anyone has small tests and benchmarks that they use for performing tests as they
develop on the MM subsystem, then we can get those in.

Matthew

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

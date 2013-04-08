Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 35ADC6B0039
	for <linux-mm@kvack.org>; Sun,  7 Apr 2013 20:27:17 -0400 (EDT)
Received: from /spool/local
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Mon, 8 Apr 2013 10:19:54 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 468932BB0054
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 10:27:09 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r380DheZ7536994
	for <linux-mm@kvack.org>; Mon, 8 Apr 2013 10:13:44 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r380R6VH011287
	for <linux-mm@kvack.org>; Mon, 8 Apr 2013 10:27:07 +1000
Date: Mon, 8 Apr 2013 08:27:04 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH part2 v6 0/3] staging: zcache: Support zero-filled pages
 more efficiently
Message-ID: <20130408002704.GA2856@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1364984183-9711-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <20130407090341.GA22589@hacker.(null)>
 <62e1fe34-e5be-42f5-83af-f8f428fce57b@default>
 <dc2642fc-f662-41cd-a236-fccf4c252dfa@default>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <dc2642fc-f662-41cd-a236-fccf4c252dfa@default>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Geert Uytterhoeven <geert@linux-m68k.org>, Fengguang Wu <fengguang.wu@intel.com>, Bob Liu <bob.liu@oracle.com>, Ric Mason <ric.masonn@gmail.com>

On Sun, Apr 07, 2013 at 10:59:18AM -0700, Dan Magenheimer wrote:
>> From: Dan Magenheimer
>> Subject: RE: [PATCH part2 v6 0/3] staging: zcache: Support zero-filled pages more efficiently
>> 
>> > From: Wanpeng Li [mailto:liwanp@linux.vnet.ibm.com]
>> > Subject: Re: [PATCH part2 v6 0/3] staging: zcache: Support zero-filled pages more efficiently
>> >
>> > Hi Dan,
>> >
>> > Some issues against Ramster:
>> >
>> 
>> Sure!  I am concerned about Konrad's patches adding debug.c as they
>> add many global variables.  They are only required when ZCACHE_DEBUG
>> is enabled so they may be ok.  If not, adding ramster variables
>> to debug.c may make the problem worse.
>
>Oops, I just noticed/remembered that ramster uses BOTH debugfs and sysfs.
>The sysfs variables are all currently required, i.e. for configuration
>so should not be tied to debugfs or a DEBUG config option.  However,
>if there is a more acceptable way to implement the function of
>those sysfs variables, that would be fine.

So if we need move debugfs counters to a single debug.c in
zcache/ramster/ and introduce RAMSTER_DEBUG? The work similiar 
as Konrad done against zcache. ;-)

Regards,
Wanpeng Li 

>
>Thanks,
>Dan
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

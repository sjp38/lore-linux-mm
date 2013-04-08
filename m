From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH part2 v6 0/3] staging: zcache: Support zero-filled pages
 more efficiently
Date: Mon, 8 Apr 2013 20:09:42 +0800
Message-ID: <34509.9611593925$1365439379@news.gmane.org>
References: <1364984183-9711-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <20130407090341.GA22589@hacker.(null)>
 <62e1fe34-e5be-42f5-83af-f8f428fce57b@default>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1UPF9d-0007zo-Qq
	for glkm-linux-mm-2@m.gmane.org; Mon, 08 Apr 2013 18:42:50 +0200
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 4D4076B00A6
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 08:10:25 -0400 (EDT)
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Mon, 8 Apr 2013 22:01:25 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 979E93578052
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 22:10:17 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r38BuLYp63766732
	for <linux-mm@kvack.org>; Mon, 8 Apr 2013 21:56:22 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r38C9jVK026110
	for <linux-mm@kvack.org>; Mon, 8 Apr 2013 22:09:46 +1000
Content-Disposition: inline
In-Reply-To: <62e1fe34-e5be-42f5-83af-f8f428fce57b@default>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Geert Uytterhoeven <geert@linux-m68k.org>, Fengguang Wu <fengguang.wu@intel.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>

On Sun, Apr 07, 2013 at 10:51:27AM -0700, Dan Magenheimer wrote:
>> From: Wanpeng Li [mailto:liwanp@linux.vnet.ibm.com]
>> Subject: Re: [PATCH part2 v6 0/3] staging: zcache: Support zero-filled pages more efficiently
>> 
>> Hi Dan,
>> 
>> Some issues against Ramster:
>> 
>> - Ramster who takes advantage of zcache also should support zero-filled
>>   pages more efficiently, correct? It doesn't handle zero-filled pages well
>>   currently.
>
>When you first posted your patchset I took a quick look at ramster
>and it looked like your patchset should work for ramster also.
>However I didn't actually run ramster to try it so there may
>be a bug.  If it doesn't work, I would very much appreciate a patch.
>

I have already fix it. ;-)

>> - Ramster DebugFS counters are exported in /sys/kernel/mm/, but zcache/frontswap/cleancache
>>   all are exported in /sys/kernel/debug/, should we unify them?
>
>That would be great.
>
>> - If ramster also should move DebugFS counters to a single file like
>>   zcache do?
>
>Sure!  I am concerned about Konrad's patches adding debug.c as they
>add many global variables.  They are only required when ZCACHE_DEBUG
>is enabled so they may be ok.  If not, adding ramster variables
>to debug.c may make the problem worse.

I move counters which use dubugfs to single file in zcache/ramster/ and 
introduce CONFIG_RAMSTER_DEBUG, patchset has already done and under test.

>
>> If you confirm these issues are make sense to fix, I will start coding. ;-)
>
>That would be great.  Note that I have a how-to for ramster here:
>
>https://oss.oracle.com/projects/tmem/dist/files/RAMster/HOWTO-120817 
>
>If when you are testing you find that this how-to has mistakes,
>please let me know.  Or feel free to add the (corrected) how-to file
>as a patch in your patchset.
>

Ok, I will add it to my patchset. ;-)

Regards,
Wanpeng Li 

>Thanks very much, Wanpeng, for your great contributions!
>
>(Ric, since you have expressed interest in ramster, if you try it and
>find corrections to the how-to file above, your input would be
>very much appreciated also!)
>
>Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

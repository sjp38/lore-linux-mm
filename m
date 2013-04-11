From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH 00/10] staging: zcache/ramster: fix and ramster/debugfs
 improvement
Date: Fri, 12 Apr 2013 07:20:42 +0800
Message-ID: <13026.0404585444$1365722457@news.gmane.org>
References: <1365553560-32258-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <399a2a41-fa4d-41d9-80aa-5b4c51fee68e@default>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1UQQnV-0007sc-BQ
	for glkm-linux-mm-2@m.gmane.org; Fri, 12 Apr 2013 01:20:53 +0200
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 7BA4B6B0005
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 19:20:50 -0400 (EDT)
Received: from /spool/local
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Fri, 12 Apr 2013 04:45:40 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 43017394004F
	for <linux-mm@kvack.org>; Fri, 12 Apr 2013 04:50:44 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3BNKe8N6095124
	for <linux-mm@kvack.org>; Fri, 12 Apr 2013 04:50:40 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3BNKhOn030351
	for <linux-mm@kvack.org>; Fri, 12 Apr 2013 09:20:43 +1000
Content-Disposition: inline
In-Reply-To: <399a2a41-fa4d-41d9-80aa-5b4c51fee68e@default>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Bob Liu <bob.liu@oracle.com>

On Thu, Apr 11, 2013 at 10:17:56AM -0700, Dan Magenheimer wrote:
>> From: Wanpeng Li [mailto:liwanp@linux.vnet.ibm.com]
>> Sent: Tuesday, April 09, 2013 6:26 PM
>> To: Greg Kroah-Hartman
>> Cc: Dan Magenheimer; Seth Jennings; Konrad Rzeszutek Wilk; Minchan Kim; linux-mm@kvack.org; linux-
>> kernel@vger.kernel.org; Andrew Morton; Bob Liu; Wanpeng Li
>> Subject: [PATCH 00/10] staging: zcache/ramster: fix and ramster/debugfs improvement
>> 
>> Fix bugs in zcache and rips out the debug counters out of ramster.c and
>> sticks them in a debug.c file. Introduce accessory functions for counters
>> increase/decrease, they are available when config RAMSTER_DEBUG, otherwise
>> they are empty non-debug functions. Using an array to initialize/use debugfs
>> attributes to make them neater. Dan Magenheimer confirm these works
>> are needed. http://marc.info/?l=linux-mm&m=136535713106882&w=2
>> 
>> Patch 1~2 fix bugs in zcache
>> 
>> Patch 3~8 rips out the debug counters out of ramster.c and sticks them
>> 		  in a debug.c file
>> 
>> Patch 9 fix coding style issue introduced in zcache2 cleanups
>>         (s/int/bool + debugfs movement) patchset
>> 
>> Patch 10 add how-to for ramster
>
>Note my preference to not apply patch 2of10 (which GregKH may choose

Ok. 

>to override), but for all, please add my:
>Acked-by: Dan Magenheimer <dan.magenheimer@oracle.com>

Thanks, Dan. ;-)

Regards,
Wanpeng Li 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

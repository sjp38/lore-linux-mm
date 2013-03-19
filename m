From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v3 0/5] zcache: Support zero-filled pages more efficiently
Date: Tue, 19 Mar 2013 09:13:59 +0800
Message-ID: <298.4712752097$1363655691@news.gmane.org>
References: <1363314860-22731-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <20130319002359.GA29441@kroah.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1UHl8a-0006GB-DJ
	for glkm-linux-mm-2@m.gmane.org; Tue, 19 Mar 2013 02:14:49 +0100
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 8C2DE6B0005
	for <linux-mm@kvack.org>; Mon, 18 Mar 2013 21:14:20 -0400 (EDT)
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 19 Mar 2013 11:06:00 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 1BC862CE804D
	for <linux-mm@kvack.org>; Tue, 19 Mar 2013 12:14:03 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r2J111bE66715762
	for <linux-mm@kvack.org>; Tue, 19 Mar 2013 12:01:02 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r2J1E1E1014258
	for <linux-mm@kvack.org>; Tue, 19 Mar 2013 12:14:01 +1100
Content-Disposition: inline
In-Reply-To: <20130319002359.GA29441@kroah.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Mar 18, 2013 at 05:23:59PM -0700, Greg Kroah-Hartman wrote:
>On Fri, Mar 15, 2013 at 10:34:15AM +0800, Wanpeng Li wrote:
>> Changelog:
>>  v2 -> v3:
>>   * increment/decrement zcache_[eph|pers]_zpages for zero-filled pages, spotted by Dan 
>>   * replace "zero" or "zero page" by "zero_filled_page", spotted by Dan
>>  v1 -> v2:
>>   * avoid changing tmem.[ch] entirely, spotted by Dan.
>>   * don't accumulate [eph|pers]pageframe and [eph|pers]zpages for 
>>     zero-filled pages, spotted by Dan
>>   * cleanup TODO list
>>   * add Dan Acked-by.
>
>In the future, please make the subject: lines have "staging: zcache:" in
>them, so I don't have to edit them by hand.

Ok, I will do them. thanks Greg. :-)

Regards,
Wanpeng Li 

>
>thanks,
>
>greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

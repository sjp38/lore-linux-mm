Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 13DF26B00E0
	for <linux-mm@kvack.org>; Sun, 26 May 2013 19:51:45 -0400 (EDT)
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Mon, 27 May 2013 20:48:56 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id C88582BB0050
	for <linux-mm@kvack.org>; Mon, 27 May 2013 09:51:40 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4QNbHdB18874612
	for <linux-mm@kvack.org>; Mon, 27 May 2013 09:37:17 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4QNpdI4021120
	for <linux-mm@kvack.org>; Mon, 27 May 2013 09:51:40 +1000
Date: Mon, 27 May 2013 07:51:38 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [patch v2 3/6] mm/memory_hotplug: Disable memory hotremove for
 32bit
Message-ID: <20130526235138.GA3223@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1369547921-24264-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1369547921-24264-3-git-send-email-liwanp@linux.vnet.ibm.com>
 <20130526090054.GE10651@dhcp22.suse.cz>
 <20130526090617.GA28604@hacker.(null)>
 <20130526181209.GB20270@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130526181209.GB20270@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, David Rientjes <rientjes@google.com>, Jiang Liu <jiang.liu@huawei.com>, Tang Chen <tangchen@cn.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org

On Sun, May 26, 2013 at 08:12:09PM +0200, Michal Hocko wrote:
>On Sun 26-05-13 17:06:17, Wanpeng Li wrote:
>> On Sun, May 26, 2013 at 11:00:54AM +0200, Michal Hocko wrote:
>> >On Sun 26-05-13 13:58:38, Wanpeng Li wrote:
>> >> As KOSAKI Motohiro mentioned, memory hotplug don't support 32bit since 
>> >> it was born, 
>> >
>> >Why? any reference? This reasoning is really weak.
>> >
>> 
>> http://marc.info/?l=linux-mm&m=136953099010171&w=2
>
>I have seen the email but that email just states that the feature is
>broken. Maybe it is obvious to you _what_ is actually broken but it
>doesn't need to be others especially those who would be reading such
>changelog later. So if you consider this configuration broken then be
>specific what is broken.
>

Sorry for the not enough information. KOSAKI explain more here:
http://marc.info/?l=linux-mm&m=136958040921274&w=2 

>-- 
>Michal Hocko
>SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id D6C176B02A5
	for <linux-mm@kvack.org>; Thu, 12 Aug 2010 20:48:24 -0400 (EDT)
Message-ID: <4C649655.8070009@goop.org>
Date: Thu, 12 Aug 2010 17:48:21 -0700
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: [Xen-devel] Re: [PATCH] GSoC 2010 - Memory hotplug support for
 Xen guests - third fully working version
References: <20100812012224.GA16479@router-fw-old.local.net-space.pl> <4C6495DC.4030005@goop.org>
In-Reply-To: <4C6495DC.4030005@goop.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daniel Kiper <dkiper@net-space.pl>
Cc: xen-devel@lists.xensource.com, stefano.stabellini@eu.citrix.com, konrad.wilk@oracle.com, linux-kernel@vger.kernel.org, v.tolstov@selfip.ru, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

  On 08/12/2010 05:46 PM, Jeremy Fitzhardinge wrote:
>> diff --git a/drivers/xen/Kconfig b/drivers/xen/Kconfig index 
>> fad3df2..4f35eaf 100644 --- a/drivers/xen/Kconfig +++ 
>> b/drivers/xen/Kconfig @@ -9,6 +9,16 @@ config XEN_BALLOON the system 
>> to expand the domain's memory allocation, or alternatively return 
>> unneeded memory to the system. +config XEN_BALLOON_MEMORY_HOTPLUG + 
>> bool "Xen memory balloon driver with memory hotplug support" + 
>> default n + depends on XEN_BALLOON && MEMORY_HOTPLUG + help + Xen 
>> memory balloon driver with memory hotplug support allows expanding + 
>> memory available for the system above limit declared at system 
>> startup. + It is very useful on critical systems which require long 
>> run without + rebooting. + config XEN_SCRUB_PAGES bool "Scrub pages 
>> before returning them to system" depends on XEN_BALLOON diff --git 
>> a/drivers/xen/balloon.c b/drivers/xen/balloon.c index 

Gah, what a mess.  Will repost later.

     J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

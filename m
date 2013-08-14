Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id A35B76B0032
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 16:40:32 -0400 (EDT)
Received: from /spool/local
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nfont@linux.vnet.ibm.com>;
	Thu, 15 Aug 2013 02:03:00 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 7997F3940059
	for <linux-mm@kvack.org>; Thu, 15 Aug 2013 02:10:18 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7EKflGo35389572
	for <linux-mm@kvack.org>; Thu, 15 Aug 2013 02:11:50 +0530
Received: from d28av02.in.ibm.com (localhost [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r7EKeMCf029378
	for <linux-mm@kvack.org>; Thu, 15 Aug 2013 02:10:22 +0530
Message-ID: <520BEB31.6090103@linux.vnet.ibm.com>
Date: Wed, 14 Aug 2013 15:40:17 -0500
From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] drivers: base: dynamic memory block creation
References: <1376508705-3188-1-git-send-email-sjenning@linux.vnet.ibm.com>
In-Reply-To: <1376508705-3188-1-git-send-email-sjenning@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Dave Hansen <dave@sr71.net>, Cody P Schafer <cody@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Lai Jiangshan <laijs@cn.fujitsu.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 08/14/2013 02:31 PM, Seth Jennings wrote:
> Large memory systems (~1TB or more) experience boot delays on the order
> of minutes due to the initializing the memory configuration part of
> sysfs at /sys/devices/system/memory/.

With the previous work that has been done in the memory sysfs layout
I think you need machines with 8 or 16+ TB of memory to see boot delays
that are measured in minutes. The boot delay is there, and with larger
memory systems in he future it will only get worse.

> 
> ppc64 has a normal memory block size of 256M (however sometimes as low
> as 16M depending on the system LMB size), and (I think) x86 is 128M.  With
> 1TB of RAM and a 256M block size, that's 4k memory blocks with 20 sysfs
> entries per block that's around 80k items that need be created at boot
> time in sysfs.  Some systems go up to 16TB where the issue is even more
> severe.
> 

It should also be pointed out that the number of sysfs entries created on
16+ TB system is 100k+. At his scale it is not really human readable to
list all of the entries. The amount of resources used to create all of the
uderlying structures for each of the entries starts to add up also.

I think an approach such as this makes the sysfs memory layout more
human readable and saves on resources.

-Nathan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

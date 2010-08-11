Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id A62786B02A5
	for <linux-mm@kvack.org>; Wed, 11 Aug 2010 11:19:35 -0400 (EDT)
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by e3.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o7BF40VW008219
	for <linux-mm@kvack.org>; Wed, 11 Aug 2010 11:04:00 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o7BFJ1OJ385140
	for <linux-mm@kvack.org>; Wed, 11 Aug 2010 11:19:01 -0400
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o7BFIsZo025170
	for <linux-mm@kvack.org>; Wed, 11 Aug 2010 09:18:54 -0600
Subject: Re: [PATCH 0/8] v5 De-couple sysfs memory directories from memory
 sections
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <4C60407C.2080608@austin.ibm.com>
References: <4C60407C.2080608@austin.ibm.com>
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Date: Wed, 11 Aug 2010 08:18:52 -0700
Message-ID: <1281539932.6988.39.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nathan Fontenot <nfont@austin.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@ozlabs.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Greg KH <greg@kroah.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2010-08-09 at 12:53 -0500, Nathan Fontenot wrote:
> This set of patches de-couples the idea that there is a single
> directory in sysfs for each memory section.  The intent of the
> patches is to reduce the number of sysfs directories created to
> resolve a boot-time performance issue.  On very large systems
> boot time are getting very long (as seen on powerpc hardware)
> due to the enormous number of sysfs directories being created.
> On a system with 1 TB of memory we create ~63,000 directories.
> For even larger systems boot times are being measured in hours. 

Hi Nathan,

The set is looking pretty good to me.  We _might_ want to up the ante in
the future and allow it to be even more dynamic than this, but this
looks like a good start to me.

BTW, have you taken a look at what the hotplug events look like if only
a single section (not filling up a whole block) is added?  

Feel free to add my:

Acked-by: Dave Hansen <dave@linux.vnet.ibm.com>

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

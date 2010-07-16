Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id B6A1F6B02A4
	for <linux-mm@kvack.org>; Fri, 16 Jul 2010 13:16:42 -0400 (EDT)
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by e7.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o6GH46x9009327
	for <linux-mm@kvack.org>; Fri, 16 Jul 2010 13:04:06 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o6GHGcxF2396346
	for <linux-mm@kvack.org>; Fri, 16 Jul 2010 13:16:38 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o6GHGbhS022878
	for <linux-mm@kvack.org>; Fri, 16 Jul 2010 13:16:38 -0400
Subject: Re: [PATCH 3/5] v2 Change the mutex name in the memory_block struct
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <4C3F55FC.4050205@austin.ibm.com>
References: <4C3F53D1.3090001@austin.ibm.com>
	 <4C3F55FC.4050205@austin.ibm.com>
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Date: Fri, 16 Jul 2010 10:16:35 -0700
Message-ID: <1279300595.9207.223.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nathan Fontenot <nfont@austin.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@ozlabs.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2010-07-15 at 13:39 -0500, Nathan Fontenot wrote:
> 
> Change the name of the memory_block mutex since it is now used for
> more than just gating changes to the status of the memory sections
> covered by the memory sysfs directory.

Heh, sorry about the previous comments. :)

You should move this up to be the first in the series.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

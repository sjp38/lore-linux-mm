Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l91FYcW7024448
	for <linux-mm@kvack.org>; Mon, 1 Oct 2007 11:34:38 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l91FYc9h477826
	for <linux-mm@kvack.org>; Mon, 1 Oct 2007 09:34:38 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l91FYcNP007531
	for <linux-mm@kvack.org>; Mon, 1 Oct 2007 09:34:38 -0600
Subject: Hotplug memory remove
From: Badari Pulavarty <pbadari@gmail.com>
Content-Type: text/plain
Date: Mon, 01 Oct 2007 08:37:43 -0700
Message-Id: <1191253063.29581.7.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kamezawa.hiroyu@jp.fujitsu.com
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

I am trying to test hotplug memory remove support on ppc64.
I have few questions (sorry if they are stupid), hoping you could 
help me.

1) Other than remove_memory(), I don't see any other arch-specific
code that needs to be provided. Even remove_memory() looks pretty
arch independent. Isn't it ?

2) I copied remove_memory() from IA64 to PPC64. When I am testing
hotplug-remove (echo offline > state), I am not able to remove
any memory at all. I get different type of failures like ..

memory offlining 6e000 to 6f000 failed

- OR -

Offlined Pages 0

I am wondering, how did you test it on IA64 ? Am I missing something ?
How can I find which "sections" of the memory are free to remove ?
I am using /proc/page_owner to figure it out for now.


Thanks,
Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

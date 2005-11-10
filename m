Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id jAAHleGJ004701
	for <linux-mm@kvack.org>; Thu, 10 Nov 2005 12:47:40 -0500
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id jAAHmqlu067026
	for <linux-mm@kvack.org>; Thu, 10 Nov 2005 10:48:52 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id jAAHle8a028211
	for <linux-mm@kvack.org>; Thu, 10 Nov 2005 10:47:40 -0700
Message-ID: <437387B5.2000205@austin.ibm.com>
Date: Thu, 10 Nov 2005 11:47:33 -0600
From: Joel Schopp <jschopp@austin.ibm.com>
MIME-Version: 1.0
Subject: Re: [Lhms-devel] [Patch:RFC] New zone ZONE_EASY_RECLAIM[0/5]
References: <20051110185754.0230.Y-GOTO@jp.fujitsu.com>
In-Reply-To: <20051110185754.0230.Y-GOTO@jp.fujitsu.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>, Linux Hotplug Memory Support <lhms-devel@lists.sourceforge.net>, Nick Piggin <nickpiggin@yahoo.com.au>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Yasunori Goto wrote:
> Hello.
> 
> I rewrote patches to create new zone as ZONE_EASY_RECLAIM.

Just to be clear.  These patches create the new zone, but they don't seem to 
actually use it to separate out removable memory, or to do memory remove.  I 
assume those patches will come later?  In any case this is a good start.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

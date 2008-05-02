Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m42HKdDk011742
	for <linux-mm@kvack.org>; Fri, 2 May 2008 13:20:39 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m42HKcMo125864
	for <linux-mm@kvack.org>; Fri, 2 May 2008 11:20:39 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m42HKcFt007780
	for <linux-mm@kvack.org>; Fri, 2 May 2008 11:20:38 -0600
Subject: Re: [RFC][PATCH 2/2] Add huge page backed stack support
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <1209748286.7763.34.camel@nimitz.home.sr71.net>
References: <1209693109.8483.23.camel@grover.beaverton.ibm.com>
	 <1209748286.7763.34.camel@nimitz.home.sr71.net>
Content-Type: text/plain
Date: Fri, 02 May 2008 10:20:35 -0700
Message-Id: <1209748835.7763.41.camel@nimitz.home.sr71.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ebmunson@us.ibm.com
Cc: linux-mm@kvack.org, nacc <nacc@linux.vnet.ibm.com>, mel@csn.ul.ie, andyw <andyw@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Fri, 2008-05-02 at 10:11 -0700, Dave Hansen wrote:
> Why don't huge page stacks need to be expanded like this?  With a large
> EXTRA_STACK_VM_PAGES, you would surely need this, right?

Never mind.  You don't expand stacks.  This one is probably worth a
comment.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

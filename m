Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e34.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j4QKxQcE105414
	for <linux-mm@kvack.org>; Thu, 26 May 2005 16:59:26 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j4QKxQhT199336
	for <linux-mm@kvack.org>; Thu, 26 May 2005 14:59:26 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j4QKxQax021250
	for <linux-mm@kvack.org>; Thu, 26 May 2005 14:59:26 -0600
Subject: Re: defrag memory
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <6934efce0505261214345a609f@mail.gmail.com>
References: <6934efce0505261214345a609f@mail.gmail.com>
Content-Type: text/plain
Date: Thu, 26 May 2005 13:59:18 -0700
Message-Id: <1117141158.27082.22.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jared Hulbert <jaredeh@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2005-05-26 at 12:14 -0700, Jared Hulbert wrote:
> Is there a kernel mechanism to force a defrag of memory?

No.

There are a few efforts (external patches) to decrease fragmentation to
allow for more ease in removing memory, or allocating larger physically
contiguous areas, but nothing in mainline or -mm.

Is there a particular reason you're interested?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

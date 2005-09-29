Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j8TFC1tQ022501
	for <linux-mm@kvack.org>; Thu, 29 Sep 2005 11:12:01 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j8TFC1VU091000
	for <linux-mm@kvack.org>; Thu, 29 Sep 2005 11:12:01 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j8TFC0K2026113
	for <linux-mm@kvack.org>; Thu, 29 Sep 2005 11:12:01 -0400
Subject: Re: [patch 1/6] Page host virtual assist: base patch.
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20050929131525.GB5700@skybase.boeblingen.de.ibm.com>
References: <20050929131525.GB5700@skybase.boeblingen.de.ibm.com>
Content-Type: text/plain
Date: Thu, 29 Sep 2005 08:11:56 -0700
Message-Id: <1128006716.6339.14.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>, frankeh@watson.ibm.com, rhim@cc.gatech.edu
List-ID: <linux-mm.kvack.org>

On Thu, 2005-09-29 at 15:15 +0200, Martin Schwidefsky wrote:
> Allocated pages start out in stable state. What prevents a page from
> being made volatile? There are 10 conditions:
...
> 5) The page is anonymous. The page has no backing, can't recreate it.

Anonymous pages still in the swap cache have backing, right?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

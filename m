Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e31.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id iABJAoCB490106
	for <linux-mm@kvack.org>; Thu, 11 Nov 2004 14:10:50 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id iABJAo1p269022
	for <linux-mm@kvack.org>; Thu, 11 Nov 2004 12:10:50 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id iABJAnxj004008
	for <linux-mm@kvack.org>; Thu, 11 Nov 2004 12:10:50 -0700
Subject: Re: [Fwd: Page allocator doubt]
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <41937940.9070001@tteng.com.br>
References: <41937940.9070001@tteng.com.br>
Content-Type: text/plain
Message-Id: <1100200247.932.1145.camel@localhost>
Mime-Version: 1.0
Date: Thu, 11 Nov 2004 11:10:47 -0800
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Luciano A. Stertz" <luciano@tteng.com.br>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2004-11-11 at 06:37, Luciano A. Stertz wrote:
> Only the first page got it page counter incremented. Is this expected?

Yes.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

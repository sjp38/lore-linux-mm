Received: from sp1n293en1.watson.ibm.com (sp1n293en1.watson.ibm.com [9.2.112.57])
	by igw2.watson.ibm.com (8.11.4/8.11.4) with ESMTP id h1RLlDj32060
	for <linux-mm@kvack.org>; Thu, 27 Feb 2003 16:47:13 -0500
Received: from watson.ibm.com (discohall.watson.ibm.com [9.2.17.22])
	by sp1n293en1.watson.ibm.com (8.11.4/8.11.4) with ESMTP id h1RLlCV51024
	for <linux-mm@kvack.org>; Thu, 27 Feb 2003 16:47:12 -0500
Message-ID: <3E5E8832.688AE0CB@watson.ibm.com>
Date: Thu, 27 Feb 2003 16:50:42 -0500
From: "Raymond B. Jennings III" <raymondj@watson.ibm.com>
Reply-To: raymondj@watson.ibm.com
MIME-Version: 1.0
Subject: Top 128MB of virtual address space
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

For linux running on an Intel machine without PAE, the top 128MB of
virtual address space:

If
PKMAP_BASE = FE000000

and
FIXADDR_START=FFF55000

That leaves a 32MB area.  I believe the permanent highmem mappings are
1024 pages so that leaves 28MB of address space.  What is this space
used for if anything?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>

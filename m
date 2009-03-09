Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 5A41E6B003D
	for <linux-mm@kvack.org>; Mon,  9 Mar 2009 08:56:21 -0400 (EDT)
Message-ID: <49B511E9.8030405@nokia.com>
Date: Mon, 09 Mar 2009 14:56:09 +0200
From: Aaro Koskinen <aaro.koskinen@nokia.com>
MIME-Version: 1.0
Subject: [RFC PATCH 0/2] mm: tlb: unmap scalability
Content-Type: text/plain; charset=iso-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hello,

Here's a patch proposal to make unmap to scale linearly on architectures 
that implement tlb_start_vma() and tlb_end_vma(), by adding range 
parameters. See <http://marc.info/?l=linux-kernel&m=123610437815468&w=2> 
for the current problem.

The first patch only adds the new parameters. The second one changes the 
ARM architecture to use those parameters. A similar change should be of 
course made also for other architectures implementing those routines.

The patch was made for 2.6.29-rc7.

A.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

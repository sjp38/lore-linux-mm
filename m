Received: from netmail.austin.ibm.com (netmail.austin.ibm.com [9.53.250.98])
	by mailgate1.austin.ibm.com (AIX4.3/8.9.3/8.9.3) with ESMTP id KAA18850
	for <linux-mm@kvack.org>; Tue, 31 Oct 2000 10:48:41 -0600
Received: from popmail.austin.ibm.com (popmail.austin.ibm.com [9.53.247.178])
        by netmail.austin.ibm.com (8.8.5/8.8.5) with ESMTP id KAA50068
        for <linux-mm@kvack.org>; Tue, 31 Oct 2000 10:47:51 -0600
Received: from us.ibm.com (slpratt2.austin.ibm.com [9.53.126.238]) by popmail.austin.ibm.com (AIX4.3/8.9.3/8.7-client1.01) with ESMTP id KAA23796 for <linux-mm@kvack.org>; Tue, 31 Oct 2000 10:47:48 -0600
Message-ID: <39FEF83C.E0EFBE28@us.ibm.com>
Date: Tue, 31 Oct 2000 10:50:04 -0600
From: Steven Pratt <slpratt@us.ibm.com>
MIME-Version: 1.0
Subject: [Fwd: [PATCH] 2.4.0-test10-pre6  TLB flush race in establish_pte]
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

 Andrea Arcangeli wrote:
 >
 > On Mon, Oct 30, 2000 at 03:31:22PM -0600, Steve Pratt/Austin/IBM
wrote:
 > > [..] no patch ever
 > > appeared. [..]
 >
 > You didn't followed l-k closely enough as the strict fix was
submitted two
 > times but it got not merged. (maybe because it had an #ifdef __s390__
that was
 > _necessary_ by that time?)
 >
 > You can find the old and now useless patch here:
 >

>ftp://ftp.us.kernel.org/pub/linux/kernel/people/andrea/patches/v2.4/2.4.0-test5/tlb-flush-smp-race-1
 
 I stand corrected, I missed this is my searching.  Hopefully this will
 get in this time.
 
> Steve
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

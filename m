Received: from austin.ibm.com (netmail2.austin.ibm.com [9.53.250.97])
	by mg02.austin.ibm.com (AIX4.3/8.9.3/8.9.3) with ESMTP id LAA29020
	for <linux-mm@kvack.org>; Wed, 18 Jul 2001 11:25:03 -0500
Received: from baldur.austin.ibm.com (baldur.austin.ibm.com [9.53.216.148])
	by austin.ibm.com (AIX4.3/8.9.3/8.9.3) with ESMTP id LAA24358
	for <linux-mm@kvack.org>; Wed, 18 Jul 2001 11:19:06 -0500
Received: from baldur (localhost.austin.ibm.com [127.0.0.1])
        by localhost.austin.ibm.com (8.12.0.Beta12/8.12.0.Beta12/Debian 8.12.0.Beta12) with ESMTP id f6IGJ6ak030609
        for <linux-mm@kvack.org>; Wed, 18 Jul 2001 11:19:06 -0500
Date: Wed, 18 Jul 2001 11:19:06 -0500
From: Dave McCracken <dmc@austin.ibm.com>
Subject: Basic MM question
Message-ID: <17230000.995473146@baldur>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

My apologies if this is a newbie question.  I'm still trying to figure out 
the fine points of how MM works.

Why does read_swap_cache_async use GFP_USER as opposed to GFP_HIGHUSER for 
swapped in pages?  Is there some characteristic of reading swap pages that 
doesn't allow use of highmem?  Since anonymous pages can be allocated from 
highmem, it seems to me it would make sense to also allow highmem pages 
once they've been swapped out and back in.

Dave McCracken

======================================================================
Dave McCracken          IBM Linux Base Kernel Team      1-512-838-3059
dmc@austin.ibm.com                                      T/L   678-3059

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

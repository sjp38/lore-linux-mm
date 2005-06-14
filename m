Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j5ELd23C017320
	for <linux-mm@kvack.org>; Tue, 14 Jun 2005 17:39:02 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j5ELd2IN263192
	for <linux-mm@kvack.org>; Tue, 14 Jun 2005 17:39:02 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j5ELd1jA005357
	for <linux-mm@kvack.org>; Tue, 14 Jun 2005 17:39:01 -0400
Received: from dyn9047017072.beaverton.ibm.com (dyn9047017072.beaverton.ibm.com [9.47.17.72])
	by d01av03.pok.ibm.com (8.12.11/8.12.11) with ESMTP id j5ELd13N005330
	for <linux-mm@kvack.org>; Tue, 14 Jun 2005 17:39:01 -0400
Subject: [RFC] PageReserved ?
From: Badari Pulavarty <pbadari@us.ibm.com>
Content-Type: text/plain
Message-Id: <1118783741.4301.357.camel@dyn9047017072.beaverton.ibm.com>
Mime-Version: 1.0
Date: 14 Jun 2005 14:15:42 -0700
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Andrew's suggestion, I am looking at possibility of getting
rid of PageReserved() usage. I see lots of drivers setting this
flag. I am wondering what was the (intended) purpose of 
PageReserved() ?


Thanks,
Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

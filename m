Date: Sat, 22 Dec 2001 11:11:13 +0530
Message-Id: <200112220541.LAA20482@inablers.net>
From: "Vishwanath K" <vishwanath@inablers.net>
Subject: few doubts on VMM
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello all,
Sorry to disturb u all, Am new to this mailing list as well as linux MM.

I want to know how exactly the virtual memory address gets converted
into physical address. I did go through the document of David A Rusling,
but still am not much clear about how exactly this memory mapping
happens, and what exactly page table contains(in address part, not the
flags).

Does kernel also mentains page table of running processes ?

As for i know page fault happens when page table has invalid bit set,
how it decides whether process is accessing the page which is not in
memory or process is accessing the memory that does not belongs to it.

Thanx in advance
Vishwanath


 \\\\||/////
oo0o0oo
---------------------------
K Vishwanath
iNabling Technologies Pvt Ltd
Rajajinagar
Ph: 3104686, 3104687
---------------------------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

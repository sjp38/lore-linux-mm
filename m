Message-ID: <3B1E52FC.C17C921F@mandrakesoft.com>
Date: Wed, 06 Jun 2001 11:57:48 -0400
From: Jeff Garzik <jgarzik@mandrakesoft.com>
MIME-Version: 1.0
Subject: Requirement: swap = RAM x 2.5 ??
References: <3B1D5ADE.7FA50CD0@illusionary.com><991815578.30689.1.camel@nomade><20010606095431.C15199@dev.sportingbet.com><0106061316300A.00553@starship> <200106061528.f56FSKa14465@vindaloo.ras.ucalgary.ca> <000701c0ee9f$515fd6a0$3303a8c0@einstein>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Christian =?iso-8859-1?Q?Borntr=E4ger?= <linux-kernel@borntraeger.net>, Derek Glidden <dglidden@illusionary.com>
List-ID: <linux-mm.kvack.org>

I'm sorry but this is a regression, plain and simple.

Previous versons of Linux have worked great on diskless workstations
with NO swap.

Swap is "extra space to be used if we have it" and nothing else.

-- 
Jeff Garzik      | Andre the Giant has a posse.
Building 1024    |
MandrakeSoft     |
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

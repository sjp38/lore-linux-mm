Received: from exch-staff1.ul.ie ([136.201.1.64])
 by ul.ie (PMDF V5.2-32 #41949) with ESMTP id <0GK6005EJUUAHA@ul.ie> for
 linux-mm@kvack.org; Mon, 24 Sep 2001 23:37:22 +0100 (BST)
Content-return: allowed
Date: Mon, 24 Sep 2001 23:41:20 +0100
From: "Gabriel.Leen" <Gabriel.Leen@ul.ie>
Subject: RE: Process not given >890MB on a 4MB machine ?????????
Message-id: <5D2F375D116BD111844C00609763076E050D1680@exch-staff1.ul.ie>
MIME-version: 1.0
Content-type: text/plain;	charset="iso-8859-1"
Content-transfer-encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "'linux-mm@kvack.org'" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hello again,
And thanks,

	>You will either need to use a true 64-bit machine (POWER, Alpha, 
	>UltraSPARC or MIPS) 

I hope (fingers crossed) that there is some way around this 
I think that Redhat  now supports up to 64GB of ram, 
as the Xeon has 36 address lines, see attached.

I'm only grasping at straws here, but I hope that it is somehow possible 
on this machine?

From:
http://support.intel.com/support/processors/pentiumiii/xeon/esma.htm
 <<...OLE_Obj...>> 
Pentium(R) III Xeon(tm) processors 
Extended Server Memory Architecture
Full 36-bit addressing allows enterprise applications to transcend 
the traditional 4GB (32-bit) memory barrier by adding 4-additional address
bits. 
PSE36 (Page size extensions) adds 4 additional address lines to the current
32 bit address. 
As each bit is added, the cacheability range doubles: 
32 bits= 4 GB 
32 + 1  	= 8 GB 
32 + 1 + 1 = 16 GB 
32 + 1 + 1 + 1 = 32
32 + 1 + 1 + 1 + 1  = 64 GB 	

	The additional headroom allows: 
	Greater than 4-gigabytes of cacheable system memory 


*********************************************************************
Gabriel Leen                        Tel:        00353  61  20 2677
PEI  Technologies               Fax:       00353  61  33 4925
Foundation Building             E-mail:   gabriel.leen@ul.ie
University of Limerick
Limerick
Ireland
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

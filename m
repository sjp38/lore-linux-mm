Message-ID: <B1DF47D78E82D511832C00B0D021B52039DC31@SAKTHI>
From: "Viju - CTD, Chennai." <viju@ctd.hcltech.com>
Subject: RE: Adding Remote mem. in local addr space.
Date: Thu, 8 Nov 2001 14:02:39 +0530 
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: amey d inamdar <iamey@rediffmail.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Hello there,
>   What will be the benefits if we can add the remote memory in local
address space? 
>  Thanx in anticipation.
> -Amey

Hello Amey,

	What i understand from ur description is u are 
trying to use the available free mem in other machine's
if some machine is running low on memory, in a network 
of systems. This would have a adverse effect if added
to the address space of any process. Since the remote mem
access is slower than the local mem access, this would make
the system much slower. This NETWORK RAM can be used only if
u have a network that would serve much faster than the local
disk access. These NETWORK RAM can be used as a backing store
for the pages that are being swapped out. This NETWORK RAM 
can be used as a intermittent layer between RAM and disk.

Regards,
Viju.


***********************************************************************
Disclaimer: 
This document is intended for transmission to the named recipient only.  If
you are not that person, you should note that legal rights reside in this
document and you are not authorized to access, read, disclose, copy, use or
otherwise deal with it and any such actions are prohibited and may be
unlawful. The views expressed in this document are not necessarily those of
HCL Technologies Ltd. Notice is hereby given that no representation,
contract or other binding obligation shall be created by this e-mail, which
must be interpreted accordingly. Any representations, contractual rights or
obligations shall be separately communicated in writing and signed in the
original by a duly authorized officer of the relevant company.
***********************************************************************


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

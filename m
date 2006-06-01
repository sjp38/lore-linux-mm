Content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Subject: ECC error correction - page isolation
Date: Thu, 1 Jun 2006 11:06:16 -0700
Message-ID: <069061BE1B26524C85EC01E0F5CC3CC30163E1F1@rigel.headquarters.spacedev.com>
From: "Brian Lindahl" <Brian.Lindahl@SpaceDev.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

We have a board that gives us access to ECC error counts and ECC error status (4 bits, each corresponding to a different error). A background process performs a scrub (read, rewrite) on individual raw memory pages to activate the ECC. When the error count changes (an error is detected), I'd like to be able to isolate the page, if unused. The pages are scrubbed as raw physical addresses (page numbers) via a ioctl command on /dev/mem. Is there a facility that will allow me to map this physical address range to a page entity in the kernel so that I can isolate it and mark it as unusable, or reboot if it's active? Is there a better way to do this (i.e. avoiding the mapping phase and interact directly with physical page entities in the kernel)? Where should I begin my journey into mm in the kernel? What structures, functions and globals should I be looking at?

Going this deep in the kernel is pretty foreign to me, so any help would be appreciated. Thanks in advance!

Brian Lindahl 
Embedded Software Engineer 
858-375-2077 
brian.lindahl@spacedev.com 
SpaceDev, Inc. 
"We Make Space Happen"
 
 
This email message and any information or files contained within or attached to this message may be privileged, confidential, proprietary and protected from disclosure and is intended only for the person or entity to which it is addressed.  This email is considered a business record and is therefore property of the SpaceDev, Inc.  Any direct or indirect review, re-transmission, dissemination, forwarding, printing, use, disclosure, or copying of this message or any part thereof or other use of or any file attached to this message, or taking of any action in reliance upon this information by persons or entities other than the intended recipient is prohibited.  If you received this message in error, please immediately inform the sender by reply e-mail and delete the message and any attachments and all copies of it from your system and destroy any hard copies of it.  No confidentiality or privilege is waived or lost by any mis-transmission.  SpaceDev, Inc. is neither liable for proper, complete transmission or the information contained in this communication, nor any delay in its receipt or any virus contained therein.  No representation, warranty or undertaking (express or implied) is given and no responsibility or liability is accepted by SpaceDev, Inc., as to the accuracy or the information contained herein or for any loss or damage (be it direct, indirect, special or other consequential) arising from reliance on it.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

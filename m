Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 8DC836B004D
	for <linux-mm@kvack.org>; Thu, 13 Aug 2009 15:41:51 -0400 (EDT)
Received: from localhost (localhost [127.0.0.1])
	by mgw1.diku.dk (Postfix) with ESMTP id EAE3F52C38D
	for <linux-mm@kvack.org>; Thu, 13 Aug 2009 21:41:39 +0200 (CEST)
Received: from mgw1.diku.dk ([127.0.0.1])
	by localhost (mgw1.diku.dk [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 1MqCj-qj8aIn for <linux-mm@kvack.org>;
	Thu, 13 Aug 2009 21:41:38 +0200 (CEST)
Received: from nhugin.diku.dk (nhugin.diku.dk [130.225.96.140])
	by mgw1.diku.dk (Postfix) with ESMTP id 929E952C380
	for <linux-mm@kvack.org>; Thu, 13 Aug 2009 21:41:38 +0200 (CEST)
Received: from ask.diku.dk (ask.diku.dk [130.225.96.225])
	by nhugin.diku.dk (Postfix) with ESMTP id 4F1C76DF845
	for <linux-mm@kvack.org>; Thu, 13 Aug 2009 21:40:31 +0200 (CEST)
Received: from localhost (localhost [127.0.0.1])
	by ask.diku.dk (Postfix) with ESMTP id 6EC05154FA0
	for <linux-mm@kvack.org>; Thu, 13 Aug 2009 21:41:38 +0200 (CEST)
Date: Thu, 13 Aug 2009 21:41:38 +0200 (CEST)
From: Julia Lawall <julia@diku.dk>
Subject: question about nommu.c
Message-ID: <Pine.LNX.4.64.0908132136540.7209@ask.diku.dk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The function vmalloc_user in the file mm/nommu.c contains the following 
code:

struct vm_area_struct *vma;
...
if (vma)
        vma->vm_flags |= VM_USERMAP;

The constant VM_USERMAP, however, is elsewhere used in a structure of type 
vm_struct, not vm_area_struct.  Furthermore, the value of VM_USERMAP is 8, 
which is the same as the value of VM_SHARED (define in mm.h), which is 
elsewhere used with a vm_area_struct structure.  Is this occurrence of 
VM_USERMAP correct?  Or should it be VM_SHARED?  Or should it be something 
else?

julia


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

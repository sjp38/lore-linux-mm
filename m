Subject: Re: [bigmem-patch] 4GB with Linux on IA32
Date: Mon, 16 Aug 1999 20:43:37 +0100 (BST)
In-Reply-To: <199908161843.LAA76017@google.engr.sgi.com> from "Kanoj Sarcar" at Aug 16, 99 11:43:33 am
Content-Type: text
Message-Id: <E11GSfS-0003ua-00@the-village.bc.nu>
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: andrea@suse.de, torvalds@transmeta.com, sct@redhat.com, Gerhard.Wichert@pdb.siemens.de, Winfried.Gerhard@pdb.siemens.de, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> a range of user pages that were in bigmem area? Also, debuggers
> want to look at user memory, so they would also need to map the
> pages. Are there any other cases where a driver might want to 

That is the tricky one. What occurs if I mmap a high memory page of
another process via /proc/pid/mem ? then write it

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/

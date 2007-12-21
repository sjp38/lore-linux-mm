Message-ID: <476B8F2B.7010409@de.ibm.com>
Date: Fri, 21 Dec 2007 11:02:19 +0100
From: Carsten Otte <cotte@de.ibm.com>
Reply-To: carsteno@de.ibm.com
MIME-Version: 1.0
Subject: Re: [rfc][patch 2/2] xip: support non-struct page memory
References: <20071214133817.GB28555@wotan.suse.de> <20071214134106.GC28555@wotan.suse.de> <476A73F0.4070704@de.ibm.com> <476A7D21.7070607@de.ibm.com> <476A8133.5050809@de.ibm.com> <20071221005049.GC31040@wotan.suse.de>
In-Reply-To: <20071221005049.GC31040@wotan.suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: carsteno@de.ibm.com, Jared Hulbert <jaredeh@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, Martin Schwidefsky <martin.schwidefsky@de.ibm.com>
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> You wouldn't even need to store it in the vm_area_struct -- you could just
> set up eg. an rb tree of flash extents, and have a function that looks up
> that tree for you.
We have a list aready, and I don't see the number of plugged extents 
get so large that rb tree saves us CPU cycles over a list implementation.
Martin Schwidefsky suggested to use a bit in the page table entry to 
prevent refcounting. fault() could set it up proper for xip pages. 
That would be way faster then walking a list. Would that be an option?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

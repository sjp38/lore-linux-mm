Message-ID: <476A8133.5050809@de.ibm.com>
Date: Thu, 20 Dec 2007 15:50:27 +0100
From: Carsten Otte <cotte@de.ibm.com>
Reply-To: carsteno@de.ibm.com
MIME-Version: 1.0
Subject: Re: [rfc][patch 2/2] xip: support non-struct page memory
References: <20071214133817.GB28555@wotan.suse.de> <20071214134106.GC28555@wotan.suse.de> <476A73F0.4070704@de.ibm.com> <476A7D21.7070607@de.ibm.com>
In-Reply-To: <476A7D21.7070607@de.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: carsteno@de.ibm.com
Cc: Nick Piggin <npiggin@suse.de>, Jared Hulbert <jaredeh@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, Martin Schwidefsky <martin.schwidefsky@de.ibm.com>
List-ID: <linux-mm.kvack.org>

Carsten Otte wrote:
> So bottom line I think we do need a different trigger then pfn_valid() 
> to select which pages within VM_MIXEDMAP get refcounted and which don't.
A poor man's solution could be, to store a pfn range of the flash chip 
and/or shared memory segment inside vm_area_struct, and in case of 
VM_MIXEDMAP we check if the pfn matches that range. If so: no 
refcounting. If not: regular refcounting. Is that an option?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

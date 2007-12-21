Message-ID: <476B8C1E.9060401@de.ibm.com>
Date: Fri, 21 Dec 2007 10:49:18 +0100
From: Carsten Otte <cotte@de.ibm.com>
Reply-To: carsteno@de.ibm.com
MIME-Version: 1.0
Subject: Re: [rfc][patch 2/2] xip: support non-struct page memory
References: <20071214133817.GB28555@wotan.suse.de> <20071214134106.GC28555@wotan.suse.de> <476A73F0.4070704@de.ibm.com> <476A7D21.7070607@de.ibm.com> <476A8133.5050809@de.ibm.com> <6934efce0712200924o4e676484j95188a01b605bfdc@mail.gmail.com>
In-Reply-To: <6934efce0712200924o4e676484j95188a01b605bfdc@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jared Hulbert <jaredeh@gmail.com>
Cc: carsteno@de.ibm.com, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, Martin Schwidefsky <martin.schwidefsky@de.ibm.com>
List-ID: <linux-mm.kvack.org>

Jared Hulbert wrote:
> I'm not picturing what is responsible for configuring this stored pfn
> range.  Does the fs do it on mount?  Does the MTD or your funky
> direct_access block driver do it?
We could set it up at mmap() time, where we do set VM_MIXEDMAP 
alltogehter.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

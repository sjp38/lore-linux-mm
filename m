Date: Sun, 21 Nov 2004 13:14:37 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH]: 3/4 mm/rmap.c cleanup
Message-Id: <20041121131437.4c3bcee0.akpm@osdl.org>
In-Reply-To: <16800.47063.386282.752478@gargle.gargle.HOWL>
References: <16800.47063.386282.752478@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nikita Danilov <nikita@clusterfs.com>
Cc: Linux-Kernel@vger.kernel.org, AKPM@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nikita Danilov <nikita@clusterfs.com> wrote:
>
> mm/rmap.c:page_referenced_one() and mm/rmap.c:try_to_unmap_one() contain
>  identical code that
> 
>   - takes mm->page_table_lock;
> 
>   - drills through page tables;
> 
>   - checks that correct pte is reached.
> 
>  Coalesce this into page_check_address()

Looks sane, but it comes at a bad time.  Please rework and resubmit after
the 4-level pagetable code is merged into Linus's tree, post-2.6.10.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

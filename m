Date: Fri, 14 Apr 2006 10:19:58 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 5/5] Swapless V2: Revise main migration logic
Message-Id: <20060414101959.d59ac82d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20060413235432.15398.23912.sendpatchset@schroedinger.engr.sgi.com>
References: <20060413235406.15398.42233.sendpatchset@schroedinger.engr.sgi.com>
	<20060413235432.15398.23912.sendpatchset@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, hugh@veritas.com, linux-kernel@vger.kernel.org, lee.schermerhorn@hp.com, linux-mm@kvack.org, taka@valinux.co.jp, marcelo.tosatti@cyclades.com
List-ID: <linux-mm.kvack.org>

On Thu, 13 Apr 2006 16:54:32 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

>
> +	inc_mm_counter(mm, anon_rss);
> +	get_page(new);
> +	set_pte_at(mm, addr, ptep, pte_mkold(mk_pte(new, vma->vm_page_prot)));
> +	page_add_anon_rmap(new, vma, addr);

Just a note:

This will cause unecessary copy-on-write later.
(current remove_from_swap() can cause copy-on-write....)
But maybe copy-on-write is just minor case for migrating specified vmas.

For hotremove (I stops it now..), we should fix this later (if we can do).
If new SWP_TYPE_MIGRATION swp entry can contain write protect bit,
hotremove can avoid copy-on-write but things will be more complicated.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

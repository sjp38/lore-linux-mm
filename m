Date: Wed, 23 Jul 2008 02:07:04 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [mmotm][PATCH 5/9] mlock-mlocked-pages-are-unevictable.patch
Message-Id: <20080723020704.3310e65f.akpm@linux-foundation.org>
In-Reply-To: <20080715041349.F6FE.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080715040402.F6EF.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<20080715041349.F6FE.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Tue, 15 Jul 2008 04:19:07 +0900 KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> Patch name: mlock-mlocked-pages-are-unevictable.patch
> Against: mmotm Jul 14
> 
> 
> unevictable-lru-infrastructure-putback_lru_page-rework.patch and unevictable-lru-infrastructure-kill-unnecessary-lock_page.patch
> makes following patch failure.

This patch (or one nearby) breaks nommu:

mm/built-in.o(.text+0x1bb70): In function `truncate_complete_page':
: undefined reference to `__clear_page_mlock'
mm/built-in.o(.text+0x1ca90): In function `__invalidate_mapping_pages':
: undefined reference to `__clear_page_mlock'
mm/built-in.o(.text+0x1d29c): In function `invalidate_inode_pages2_range':
: undefined reference to `__clear_page_mlock'

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

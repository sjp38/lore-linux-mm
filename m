Date: Thu, 5 Jun 2003 17:12:15 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH] Remove page_table_lock from vma manipulations
In-Reply-To: <149060000.1054767502@baldur.austin.ibm.com>
Message-ID: <Pine.LNX.4.44.0306051704180.3779-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmccr@us.ibm.com>
Cc: Andrew Morton <akpm@digeo.com>, Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 4 Jun 2003, Dave McCracken wrote:
> 
> Gah.  I don't know how I convinced myself that code was safe.  It's easily
> fixed.  How does this one look?

I think you have to keep page_table_lock in expand_stack (GROWSUP and
down versions) because that is called with only down_read on mmap_sem,
so two could be racing: nothing else protects the various vma field
adjustments there.  Otherwise appears correct to me.  Beneficial?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

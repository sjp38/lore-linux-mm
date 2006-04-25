Date: Tue, 25 Apr 2006 09:09:43 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 2.6.17-rc1-mm3] add migratepage addresss space op to
 shmem
In-Reply-To: <Pine.LNX.4.64.0604251153300.29020@blonde.wat.veritas.com>
Message-ID: <Pine.LNX.4.64.0604250908380.14208@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0604242046120.24647@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0604241447520.8904@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0604251153300.29020@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 25 Apr 2006, Hugh Dickins wrote:

> Perhaps.  But there seem to be altogether too many ways through this
> code: this part of migrate_pages then starts to look rather like,
> but not exactly like, swap_page.  Feels like it needs refactoring.

I will have a look at it when the conference is over. Probably Thursday.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

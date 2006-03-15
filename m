Date: Tue, 14 Mar 2006 17:16:04 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Inconsistent capabilites associated with MPOL_MOVE_ALL
In-Reply-To: <441820B0.6719.396D781@michael.kerrisk.gmx.net>
Message-ID: <Pine.LNX.4.64.0603141715340.23371@schroedinger.engr.sgi.com>
References: <441820B0.6719.396D781@michael.kerrisk.gmx.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Michael Kerrisk <michael.kerrisk@gmx.net>
Cc: Andrew Morton <akpm@osdl.org>, clameter@sgi.comclameter@sgi.com, ak@suse.de, linux-mm@kvack.org, mtk-manpages@gmx.net
List-ID: <linux-mm.kvack.org>

On Wed, 15 Mar 2006, Michael Kerrisk wrote:

> Ooops sorry about the last -- I see that Christoph is changing stuff in 
> addition to what I was proposing...  (But it makes sense to me, from a 
> consistency point of view.)

No these are all related to MPOL_MOVE_ALL. Either for mbind() or 
migrate_pages().


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

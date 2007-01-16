Date: Tue, 16 Jan 2007 11:02:10 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 4/29] Introduce Page Table Interface (PTI)
In-Reply-To: <20070113024601.29682.32487.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
Message-ID: <Pine.LNX.4.64.0701161100080.6637@schroedinger.engr.sgi.com>
References: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
 <20070113024601.29682.32487.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Davies <pauld@gelato.unsw.edu.au>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 13 Jan 2007, Paul Davies wrote:

> +	if (mm!=&init_mm) { /* Look up user page table */

Missing blanks. Comment on a separate line please.

> +#define lookup_page_table_lock(mm, pt_path, address)	\

We need the complete path to the pte here?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

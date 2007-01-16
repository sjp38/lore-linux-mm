Date: Tue, 16 Jan 2007 11:08:15 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 7/29] Continue calling simple PTI functions
In-Reply-To: <20070113024617.29682.90437.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
Message-ID: <Pine.LNX.4.64.0701161106010.6637@schroedinger.engr.sgi.com>
References: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
 <20070113024617.29682.90437.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Davies <pauld@gelato.unsw.edu.au>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 13 Jan 2007, Paul Davies wrote:

> -	pte = pte_alloc_map(mm, pmd, address);
> +	pte = build_page_table(mm, address, &pt_path);

build_page_table as a name for a function whose role is mainly to lookup 
a pte? Yes it adds entries as required. Maybe something like

lookup_and_add_page_table()


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

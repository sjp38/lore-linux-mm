Date: Mon, 14 Jun 1999 07:30:26 +0200 (CEST)
From: Rik van Riel <riel@nl.linux.org>
Subject: Re: Where is the Page Table Entry of a process kept?
In-Reply-To: <3764EDA0.75CF859F@asdc.com.cn>
Message-ID: <Pine.LNX.4.03.9906140728500.534-100000@mirkwood.nl.linux.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ZhangWeiXue <ZhangWeiXue@asdc.com.cn>
Cc: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 14 Jun 1999, ZhangWeiXue wrote:

> Page Table Entry of a process is very import to transfer virsual
> address to physical address,
> I want to know where is a process's Page Table Entry kept, which
> data struct holds the information?

It's in the page tables. The page tables are referenced through
a PDE (Pagetable Directory Entry, aka first-level page table).
The pointer to that structure can be found in the TSS structure.

cheers,

Rik -- Open Source: you deserve to be in control of your data.
+-------------------------------------------------------------------+
| Le Reseau netwerksystemen BV:               http://www.reseau.nl/ |
| Linux Memory Management site:   http://www.linux.eu.org/Linux-MM/ |
| Nederlandse Linux documentatie:          http://www.nl.linux.org/ |
+-------------------------------------------------------------------+

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/

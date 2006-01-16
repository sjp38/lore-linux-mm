Date: Sun, 15 Jan 2006 22:54:31 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: Race in new page migration code?
In-Reply-To: <43C9DD98.5000506@yahoo.com.au>
Message-ID: <Pine.LNX.4.62.0601152251550.17034@schroedinger.engr.sgi.com>
References: <20060114155517.GA30543@wotan.suse.de>
 <Pine.LNX.4.62.0601140955340.11378@schroedinger.engr.sgi.com>
 <20060114181949.GA27382@wotan.suse.de> <Pine.LNX.4.62.0601141040400.11601@schroedinger.engr.sgi.com>
 <43C9DD98.5000506@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Magnus Damm <magnus.damm@gmail.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sun, 15 Jan 2006, Nick Piggin wrote:

> OK (either way is fine), but you should still drop the __isolate_lru_page
> nonsense and revert it like my patch does.

Ok with me. Magnus: You needed the __isolate_lru_page for some other 
purpose. Is that still the case?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

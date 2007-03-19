Date: Mon, 19 Mar 2007 13:39:21 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 0/4] mlock pages off LRU
In-Reply-To: <20070312042553.5536.73828.sendpatchset@linux.site>
Message-ID: <Pine.LNX.4.64.0703191338550.8150@schroedinger.engr.sgi.com>
References: <20070312042553.5536.73828.sendpatchset@linux.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Mon, 12 Mar 2007, Nick Piggin wrote:

> Comments?

Could we also take anonymous pages off the LRU if there is no swap or not 
enough swap?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

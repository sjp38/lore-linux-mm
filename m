Date: Tue, 6 Nov 2007 18:28:19 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC PATCH 6/10] split anon and file LRUs
In-Reply-To: <20071103190158.34b4650e@bree.surriel.com>
Message-ID: <Pine.LNX.4.64.0711061825590.5249@schroedinger.engr.sgi.com>
References: <20071103184229.3f20e2f0@bree.surriel.com>
 <20071103190158.34b4650e@bree.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, 3 Nov 2007, Rik van Riel wrote:

> Split the LRU lists in two, one set for pages that are backed by
> real file systems ("file") and one for pages that are backed by
> memory and swap ("anon").  The latter includes tmpfs.

If we split the memory backed from the disk backed pages then
they are no longer competing with one another on equal terms? So the file LRU 
may run faster than the memory LRU?

The patch looks awfully large.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

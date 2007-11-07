Date: Tue, 6 Nov 2007 19:26:33 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC PATCH 3/10] define page_file_cache
In-Reply-To: <20071106221710.3f9b8dd6@bree.surriel.com>
Message-ID: <Pine.LNX.4.64.0711061920510.5746@schroedinger.engr.sgi.com>
References: <20071103184229.3f20e2f0@bree.surriel.com>
 <20071103185516.24832ab0@bree.surriel.com> <Pine.LNX.4.64.0711061821010.5249@schroedinger.engr.sgi.com>
 <20071106215552.4ab7df81@bree.surriel.com> <Pine.LNX.4.64.0711061856400.5565@schroedinger.engr.sgi.com>
 <20071106221710.3f9b8dd6@bree.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

n Tue, 6 Nov 2007, Rik van Riel wrote:

> Every anonymous, tmpfs or shared memory segment page is potentially
> swap backed. That is the whole point of the PG_swapbacked flag.

One of the current issues with anonymous pages is the accounting when 
they become file backed and get dirty. There are performance issue with 
swap writeout because we are not doing it in file order and on a page by 
page basis.

Do ramfs pages count as memory backed?
 
> A page from a filesystem like ext3 or NFS cannot suddenly turn into
> a swap backed page.  This page "nature" is not changed during the
> lifetime of a page.

Well COW sortof does that but then its a new page.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

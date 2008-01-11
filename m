Date: Fri, 11 Jan 2008 10:38:42 -0500
From: Rik van Riel <riel@redhat.com>
Subject: Re: [patch 00/19] VM pageout scalability improvements
Message-ID: <20080111103842.60133336@bree.surriel.com>
In-Reply-To: <20080111104115.GA19814@balbir.in.ibm.com>
References: <20080108205939.323955454@redhat.com>
	<20080111104115.GA19814@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 11 Jan 2008 16:11:15 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> I've just started the patch series, the compile fails for me on a
> powerpc box. global_lru_pages() is defined under CONFIG_PM, but used
> else where in mm/page-writeback.c. None of the global_lru_pages()
> parameters depend on CONFIG_PM. Here's a simple patch to fix it.

Thank you for the fix.  I have applied it to my tree.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Tue, 14 May 2002 07:20:58 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [RFC][PATCH] cache shrinking via page age
Message-ID: <20020514142058.GH15756@holomorphy.com>
References: <200205111614.29698.tomlins@cam.org> <200205120949.13081.tomlins@cam.org> <200205132238.31589.tomlins@cam.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200205132238.31589.tomlins@cam.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ed Tomlinson <tomlins@cam.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@zip.com.au>
List-ID: <linux-mm.kvack.org>

On Mon, May 13, 2002 at 10:38:31PM -0400, Ed Tomlinson wrote:
> Andrew Morton pointed out that the kernel is using 8m pages and is 
> setting reference bits for these pages...  He suggested (amoung other
> things - thanks) that setting the bits in kmem_cache_alloc would be 
> a good start to making aging happen.   This version of the patch 
> impliments his suggestion.
> Comments?
> Ed Tomlinson

8MB pages? What architecture?


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

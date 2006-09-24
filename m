Date: Sun, 24 Sep 2006 09:58:50 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] Get rid of zone_table V2
In-Reply-To: <20060924030643.e57f700c.akpm@osdl.org>
Message-ID: <Pine.LNX.4.64.0609240957130.18227@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0609181215120.20191@schroedinger.engr.sgi.com>
 <20060924030643.e57f700c.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, Andy Whitcroft <apw@shadowen.org>, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Sun, 24 Sep 2006, Andrew Morton wrote:

> arm allmodconfig:
> 
> include/linux/mm.h: In function `page_zone_id':
> include/linux/mm.h:450: warning: right shift count >= width of type

That is a sparse config problem I think. I had this when trying to get 
back from a sparse to a non sparse configuration on i386 f.e.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

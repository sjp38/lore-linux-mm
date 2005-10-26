Subject: Re: [PATCH 1/5] Swap Migration V4: LRU operations
From: Peter Zijlstra <peter@programming.kicks-ass.net>
In-Reply-To: <20051025193028.6828.27929.sendpatchset@schroedinger.engr.sgi.com>
References: <20051025193023.6828.89649.sendpatchset@schroedinger.engr.sgi.com>
	 <20051025193028.6828.27929.sendpatchset@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Wed, 26 Oct 2005 11:31:23 +0200
Message-Id: <1130319083.17653.37.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Mike Kravetz <kravetz@us.ibm.com>, Ray Bryant <raybry@mpdtxmail.amd.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Magnus Damm <magnus.damm@gmail.com>, Paul Jackson <pj@sgi.com>, Dave Hansen <haveblue@us.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2005-10-25 at 12:30 -0700, Christoph Lameter wrote:

> +		if (rc == -1) {  /* Not possible to isolate */
> +			list_del(&page->lru);
> +			list_add(&page->lru, src);
>  		}

Would the usage of list_move() not be simpler?

Peter Zijlstra

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Fri, 18 Mar 2005 15:08:26 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [RFC][PATCH 5/6] sparsemem: more separation between NUMA and
 DISCONTIG
Message-Id: <20050318150826.4ca3ad14.akpm@osdl.org>
In-Reply-To: <E1DBisA-0000l4-00@kernel.beaverton.ibm.com>
References: <E1DBisA-0000l4-00@kernel.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

Dave Hansen <haveblue@us.ibm.com> wrote:
>
>  There is some confusion with the SPARSEMEM patch between what
>  is needed for DISCONTIG vs. NUMA.  For instance, the NODE_DATA()
>  macro needs to be switched on NUMA, but not on FLATMEM.
> 
>  This patch is required if the previous patch is applied.

This patch breaks !CONFIG_NUMA ppc64:

include/linux/mmzone.h:387:1: warning: "NODE_DATA" redefined
include/asm/mmzone.h:55:1: warning: this is the location of the previous definition

I'll hack around it for now.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

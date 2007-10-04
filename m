From: Andi Kleen <ak@suse.de>
Subject: Re: [14/18] Configure stack size
Date: Thu, 4 Oct 2007 11:11:04 +0200
References: <20071004035935.042951211@sgi.com> <20071004040004.936534357@sgi.com>
In-Reply-To: <20071004040004.936534357@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200710041111.05141.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, travis@sgi.com
List-ID: <linux-mm.kvack.org>

On Thursday 04 October 2007 05:59, Christoph Lameter wrote:
> Make the stack size configurable now that we can fallback to vmalloc if
> necessary. SGI NUMA configurations may need more stack because cpumasks
> and nodemasks are at times kept on the stack.  With the coming 16k cpu 
> support 

Hmm, I was told 512 byte cpumasks for x86 earlier. Why is this suddenly 2K? 

2K is too much imho. If you really want to go that big you have
to look in allocating them all separately imho. But messing
with the stack TLB entries and risking more TLB misses 
is not a good idea.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

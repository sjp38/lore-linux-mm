From: Leandro Motta Barros <lmb@exatas.unisinos.br>
Subject: Re: __vmalloc and alloc_page
Date: Thu, 18 Sep 2003 13:20:08 -0300
References: <200309171326.11848.lmb@exatas.unisinos.br> <20030917193202.GG14079@holomorphy.com>
In-Reply-To: <20030917193202.GG14079@holomorphy.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200309181320.08605.lmb@exatas.unisinos.br>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: linux-mm@kvack.org, sisopiii-l@cscience.org
List-ID: <linux-mm.kvack.org>

On Wednesday 17 September 2003 16:32, William Lee Irwin III wrote:
> Higher-order would probably not be as useful as you'd suspect; try
> looking at the distribution of available pages of given sizes in /proc/.
> OTOH, just being able to get more than one page in one call (not relying
> on physically contiguous memory) would be a simple and useful optimization.


I'm not sure if I really understood what you said. Does it means that in some 
cases (e.g., when the buddy allocator has a free chunk of the proper size) 
this could be good, even though this will not help other things (like 
reducing the number of splits in the buddy allocator)?

LMB

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

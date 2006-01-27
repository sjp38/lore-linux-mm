Date: Fri, 27 Jan 2006 09:09:32 +0200 (EET)
From: Pekka J Enberg <penberg@cs.Helsinki.FI>
Subject: Re: [patch 8/9] slab - Add *_mempool slab variants
In-Reply-To: <43D94FC1.4050708@us.ibm.com>
Message-ID: <Pine.LNX.4.58.0601270907310.14394@sbz-30.cs.Helsinki.FI>
References: <20060125161321.647368000@localhost.localdomain>
 <1138218020.2092.8.camel@localhost.localdomain>
 <84144f020601252341k62c0c6fck57f3baa290f4430@mail.gmail.com>
 <43D94FC1.4050708@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Dobson <colpatch@us.ibm.com>
Cc: linux-kernel@vger.kernel.org, sri@us.ibm.com, andrea@suse.de, pavel@suse.cz, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 26 Jan 2006, Matthew Dobson wrote:
> The overhead of passing along a NULL pointer should not be too onerous.

It is, the extra parameter passing will be propagated all over the kernel 
where kmalloc() is called. Increasing kernel text for no good reason is 
not acceptable.

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

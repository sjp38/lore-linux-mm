Subject: Re: [patch 05/26] Slab allocators: Cleanup zeroing allocations
In-Reply-To: <Pine.LNX.4.64.0706181531410.8595@schroedinger.engr.sgi.com>
Message-ID: <YwzqCzcS.1182232109.9199150.penberg@cs.helsinki.fi>
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Date: Tue, 19 Jun 2007 08:48:29 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "suresh.b.siddha@intel.com" <suresh.b.siddha@intel.com>
List-ID: <linux-mm.kvack.org>

On 6/19/2007, "Christoph Lameter" <clameter@sgi.com> wrote:
> IA64

[snip]

> Saved ~500 bytes in text size.
> 
> x86_64:

[snip]

> 200 bytes saved.

Looks good. Thanks Christoph.

Acked-by: Pekka Enberg <penberg@cs.helsinki.fi>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

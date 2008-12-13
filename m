Return-Path: <linux-kernel-owner+w=401wt.eu-S1756856AbYLMJES@vger.kernel.org>
Message-ID: <84144f020812130103t11fb4054rb934376a034ec802@mail.gmail.com>
Date: Sat, 13 Dec 2008 11:03:51 +0200
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [rfc][patch] SLQB slab allocator
In-Reply-To: <Pine.LNX.4.64.0812122013390.15781@quilx.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20081212002518.GH8294@wotan.suse.de>
	 <Pine.LNX.4.64.0812122013390.15781@quilx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Archive: <https://lore.kernel.org/lkml/>
List-Post: <mailto:linux-kernel@vger.kernel.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, bcrl@kvack.org, list-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Dec 13, 2008 at 4:34 AM, Christoph Lameter
<cl@linux-foundation.org> wrote:
> AFAICT this is the special case that matters in terms of the database
> test you are trying to improve. The case there is likely  the result
> of bad cache unfriendly programming. You may actually improve the
> benchmark more if the cachelines would be kept hot there in the right
> way.

Lets not forget the order-0 page thing, which is nice from page
allocator fragmentation point of view. But I suppose SLUB can use them
as well if we get around fixing the page allocator fastpaths?

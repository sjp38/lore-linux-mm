Return-Path: <linux-kernel-owner+w=401wt.eu-S1756028AbYLMCgj@vger.kernel.org>
Date: Fri, 12 Dec 2008 20:36:21 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [rfc][patch] mm: kfree_size
In-Reply-To: <20081212003130.GA24497@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0812122035410.15781@quilx.com>
References: <20081212002518.GH8294@wotan.suse.de> <20081212003130.GA24497@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-kernel-owner@vger.kernel.org
List-Archive: <https://lore.kernel.org/lkml/>
List-Post: <mailto:linux-kernel@vger.kernel.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, bcrl@kvack.org, list-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 12 Dec 2008, Nick Piggin wrote:

> Allocators which don't care so much could just define kfree_size to kfree.
>
> Thoughts? Any other good candidate callers?

Would be a good idea together with some sort of allocator skeleton. Not
having to carry the size is especially important for alternate kmalloc
array implementations.

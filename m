Date: Fri, 2 Apr 2004 07:05:25 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RFC][PATCH 1/3] radix priority search tree - objrmap complexity fix
Message-ID: <20040402070525.A31581@infradead.org>
References: <20040402001535.GG18585@dualathlon.random> <Pine.LNX.4.44.0404020145490.2423-100000@localhost.localdomain> <20040402011627.GK18585@dualathlon.random> <20040401173649.22f734cd.akpm@osdl.org> <20040402020022.GN18585@dualathlon.random> <20040401180802.219ece99.akpm@osdl.org> <20040402022233.GQ18585@dualathlon.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040402022233.GQ18585@dualathlon.random>; from andrea@suse.de on Fri, Apr 02, 2004 at 04:22:33AM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Andrew Morton <akpm@osdl.org>, hugh@veritas.com, vrajesh@umich.edu, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 02, 2004 at 04:22:33AM +0200, Andrea Arcangeli wrote:
> Well, I doubt anybody could take advantage of this optimization, since
> nobody can ship with hugetlbfs disabled anyways (peraphs with the
> exception of the embedded people but then I doubt they want to risk

Common. stop smoking that bad stuff.  Almost non-one except the known
oracle whores SuSE and RH need it.  Remeber Linux is used much more widely
except the known "Enterprise" vendors.  None of the NAS/networking/media
applicances or pdas I've seen has the slightest need for hugetlbfs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

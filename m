Date: Thu, 1 Apr 2004 18:08:02 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [RFC][PATCH 1/3] radix priority search tree - objrmap
 complexity fix
Message-Id: <20040401180802.219ece99.akpm@osdl.org>
In-Reply-To: <20040402020022.GN18585@dualathlon.random>
References: <20040402001535.GG18585@dualathlon.random>
	<Pine.LNX.4.44.0404020145490.2423-100000@localhost.localdomain>
	<20040402011627.GK18585@dualathlon.random>
	<20040401173649.22f734cd.akpm@osdl.org>
	<20040402020022.GN18585@dualathlon.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: hugh@veritas.com, vrajesh@umich.edu, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli <andrea@suse.de> wrote:
>
> I now fixed up the whole compound thing, it made no sense to keep
> compound off with HUGETLBSF=N, that's a generic setup for all order > 0
> not just for hugetlbfs, so it has to be enabled always or never, or it's
> just asking for troubles.

It was a modest optimisation for non-hugetlb architectures and configs. 
Having it optional has caused no problem in a year.

Was there some reason why you _required_ that it be permanently enabled?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

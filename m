Received: by ug-out-1314.google.com with SMTP id s2so260992uge
        for <linux-mm@kvack.org>; Wed, 02 May 2007 12:18:56 -0700 (PDT)
Message-ID: <84144f020705021218v7ab2461ala215bbb034475e07@mail.gmail.com>
Date: Wed, 2 May 2007 22:18:55 +0300
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: 2.6.22 -mm merge plans: slub
In-Reply-To: <Pine.LNX.4.64.0705021158150.1220@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070430162007.ad46e153.akpm@linux-foundation.org>
	 <20070501125559.9ab42896.akpm@linux-foundation.org>
	 <Pine.LNX.4.64.0705012101410.26170@blonde.wat.veritas.com>
	 <Pine.LNX.4.64.0705011403470.26819@schroedinger.engr.sgi.com>
	 <Pine.LNX.4.64.0705021330001.16517@blonde.wat.veritas.com>
	 <Pine.LNX.4.64.0705021017270.32635@schroedinger.engr.sgi.com>
	 <Pine.LNX.4.64.0705021924200.24456@blonde.wat.veritas.com>
	 <Pine.LNX.4.64.0705021137210.1027@schroedinger.engr.sgi.com>
	 <20070502115725.683ac702.akpm@linux-foundation.org>
	 <Pine.LNX.4.64.0705021158150.1220@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, haveblue@ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 5/2/07, Christoph Lameter <clameter@sgi.com> wrote:
> Owww... You throw my roadmap out of the window and may create too
> high expectations of SLUB.

Me too!

On 5/2/07, Christoph Lameter <clameter@sgi.com> wrote:
> I am the one who has to maintain SLAB and SLUB it seems and I have been
> dealing with the trio SLAB, SLOB and SLUB for awhile now. Its okay and it
> will be much easier once the cleanups are in.

And then there's patches such as kmemleak which would need to target
all three. Plus it doesn't really make sense for users to select
between three competiting implementations. Please don't take away our
high hopes of getting rid of mm/slab.c Christoph =)

                                      Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

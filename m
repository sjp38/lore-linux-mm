Date: Mon, 14 Mar 2005 22:10:45 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] mm counter operations through macros
In-Reply-To: <20050314215958.15544c65.akpm@osdl.org>
Message-ID: <Pine.LNX.4.58.0503142209511.16889@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.58.0503110422150.19280@schroedinger.engr.sgi.com>
 <20050311182500.GA4185@redhat.com> <Pine.LNX.4.58.0503111103200.22240@schroedinger.engr.sgi.com>
 <16946.62799.737502.923025@gargle.gargle.HOWL>
 <Pine.LNX.4.58.0503142103090.16582@schroedinger.engr.sgi.com>
 <20050314214506.050efadf.akpm@osdl.org> <Pine.LNX.4.58.0503142148510.16812@schroedinger.engr.sgi.com>
 <20050314215958.15544c65.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: nikita@clusterfs.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 14 Mar 2005, Andrew Morton wrote:

> >  Then you wont be able to get rid of the counters by
> >
> >  #define MM_COUNTER(xx)
> >
> >  anymore.
>
> Why would we want to do that?

If counters are calculated on demand then no counter is
necessary.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

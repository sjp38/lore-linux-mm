Received: by nz-out-0506.google.com with SMTP id s1so422091nze
        for <linux-mm@kvack.org>; Mon, 20 Aug 2007 02:28:10 -0700 (PDT)
Message-ID: <84144f020708200228v1af5248cx6f6da4a7a35400f3@mail.gmail.com>
Date: Mon, 20 Aug 2007 12:28:09 +0300
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [PATCH 04/10] mm: slub: add knowledge of reserve pages
In-Reply-To: <1187601455.6114.189.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070806102922.907530000@chello.nl>
	 <20070806103658.603735000@chello.nl> <1187595513.6114.176.camel@twins>
	 <Pine.LNX.4.64.0708201211240.20591@sbz-30.cs.Helsinki.FI>
	 <1187601455.6114.189.camel@twins>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>, Christoph Lameter <clameter@sgi.com>, Matt Mackall <mpm@selenic.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Steve Dickson <SteveD@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi Peter,

On Mon, 2007-08-20 at 12:12 +0300, Pekka J Enberg wrote:
> > Any reason why the callers that are actually interested in this don't do
> > page->reserve on their own?

On 8/20/07, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> because new_slab() destroys the content?

Right. So maybe we could move the initialization parts of new_slab()
to __new_slab() so that the callers that are actually interested in
'reserve' could do allocate_slab(), store page->reserve and do rest of
the initialization with it?

As for the __GFP_WAIT handling, I *think* we can move the interrupt
enable/disable to allocate_slab()... Christoph?

                                       Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

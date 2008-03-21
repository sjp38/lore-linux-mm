Date: Fri, 21 Mar 2008 00:03:51 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [14/14] vcompound: Avoid vmalloc for ehash_locks
In-Reply-To: <47E35D73.6060703@cosmosbay.com>
Message-ID: <Pine.LNX.4.64.0803210002450.15903@schroedinger.engr.sgi.com>
References: <20080321061703.921169367@sgi.com> <20080321061727.491610308@sgi.com>
 <47E35D73.6060703@cosmosbay.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Linux Netdev List <netdev@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, 21 Mar 2008, Eric Dumazet wrote:

> But, isnt it defeating the purpose of this *particular* vmalloc() use ?

I thought that was controlled by hashdist? I did not see it used here and 
so I assumed that the RR was not intended here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

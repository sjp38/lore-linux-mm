From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH 00/33] Swap over NFS -v14
Date: Wed, 31 Oct 2007 15:04:23 +1100
References: <20071030160401.296770000@chello.nl> <200710311426.33223.nickpiggin@yahoo.com.au> <20071030.213753.126064697.davem@davemloft.net>
In-Reply-To: <20071030.213753.126064697.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200710311504.24016.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Miller <davem@davemloft.net>
Cc: a.p.zijlstra@chello.nl, torvalds@linux-foundation.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no
List-ID: <linux-mm.kvack.org>

On Wednesday 31 October 2007 15:37, David Miller wrote:
> From: Nick Piggin <nickpiggin@yahoo.com.au>
> Date: Wed, 31 Oct 2007 14:26:32 +1100
>
> > Is it really worth all the added complexity of making swap
> > over NFS files work, given that you could use a network block
> > device instead?
>
> Don't be misled.  Swapping over NFS is just a scarecrow for the
> seemingly real impetus behind these changes which is network storage
> stuff like iSCSI.

Oh, I'm OK with the network reserves stuff (not the actual patch,
which I'm not really qualified to review, but at least the idea
of it...).

And also I'm not as such against the idea of swap over network.

However, specifically the change to make swapfiles work through
the filesystem layer (ATM it goes straight to the block layer,
modulo some initialisation stuff which uses block filesystem-
specific calls).

I mean, I assume that anybody trying to swap over network *today*
has to be using a network block device anyway, so the idea of
just being able to transparently improve that case seems better
than adding new complexities for seemingly not much gain.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Tue, 30 Oct 2007 21:37:53 -0700 (PDT)
Message-Id: <20071030.213753.126064697.davem@davemloft.net>
Subject: Re: [PATCH 00/33] Swap over NFS -v14
From: David Miller <davem@davemloft.net>
In-Reply-To: <200710311426.33223.nickpiggin@yahoo.com.au>
References: <20071030160401.296770000@chello.nl>
	<200710311426.33223.nickpiggin@yahoo.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Wed, 31 Oct 2007 14:26:32 +1100
Return-Path: <owner-linux-mm@kvack.org>
To: nickpiggin@yahoo.com.au
Cc: a.p.zijlstra@chello.nl, torvalds@linux-foundation.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no
List-ID: <linux-mm.kvack.org>

> Is it really worth all the added complexity of making swap
> over NFS files work, given that you could use a network block
> device instead?

Don't be misled.  Swapping over NFS is just a scarecrow for the
seemingly real impetus behind these changes which is network storage
stuff like iSCSI.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

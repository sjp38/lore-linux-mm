Date: Thu, 21 Oct 2004 20:09:35 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH] Migration cache
In-Reply-To: <20041021103005.GA18917@logos.cnet>
Message-ID: <Pine.LNX.4.44.0410212005590.12985-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: Hirokazu Takahashi <taka@valinux.co.jp>, haveblue@us.ibm.com, iwamoto@valinux.co.jp, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 21 Oct 2004, Marcelo Tosatti wrote:
> On Thu, Oct 21, 2004 at 02:10:44AM +0900, Hirokazu Takahashi wrote:
> > 
> > I guess it would be better to reserve one swap type for the migration
> > cache instead of reserving the bit to reduce the impact of the maximum
> > number of swap types.

I thought the same ...

> By reserving one swap type we would also use a bit. Using a swap type is 
> the same thing as using a bit in the swap pagetableentry. (the swap type 
> has 5 bits reserved for swap devices, 2^5 = 32 swap devices).

... and don't understand your response.

Reserving a swap type leaves 31 swap devices for normal use, okay;
but reserving a bit leaves only 16 swap devices for normal use.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

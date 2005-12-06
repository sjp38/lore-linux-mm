Date: Mon, 05 Dec 2005 19:11:53 -0800 (PST)
Message-Id: <20051205.191153.19905732.davem@davemloft.net>
Subject: Re: [RFC] lockless radix tree readside
From: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <4394EC28.8050304@yahoo.com.au>
References: <4394EC28.8050304@yahoo.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Tue, 06 Dec 2005 12:40:56 +1100
Return-Path: <owner-linux-mm@kvack.org>
To: nickpiggin@yahoo.com.au
Cc: Linux-Kernel@Vger.Kernel.ORG, linux-mm@kvack.org, paul.mckenney@us.ibm.com, wfg@mail.ustc.edu.cn
List-ID: <linux-mm.kvack.org>

> I realise that radix-tree.c isn't a trivial bit of code so I don't
> expect reviews to be forthcoming, but if anyone had some spare time
> to glance over it that would be great.

I went over this a few times and didn't find any obvious
problems with the RCU aspect of this.

> Is my given detail of the implementation clear? Sufficient? Would
> diagrams be helpful?

If I were to suggest an ascii diagram for a comment, it would be
one which would show the height invariant this patch takes advantage
of.

Nice work.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

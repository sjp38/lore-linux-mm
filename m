Date: Fri, 04 May 2007 12:54:42 -0700 (PDT)
Message-Id: <20070504.125442.70218284.davem@davemloft.net>
Subject: Re: [PATCH 00/40] Swap over Networked storage -v12
From: David Miller <davem@davemloft.net>
In-Reply-To: <170fa0d20705041109j1d130456p4b7cef3633f8edb4@mail.gmail.com>
References: <1178293081.24217.46.camel@twins>
	<1178294379.7997.26.camel@imap.mvista.com>
	<170fa0d20705041109j1d130456p4b7cef3633f8edb4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: "Mike Snitzer" <snitzer@gmail.com>
Date: Fri, 4 May 2007 14:09:40 -0400
Return-Path: <owner-linux-mm@kvack.org>
To: snitzer@gmail.com
Cc: dwalker@mvista.com, a.p.zijlstra@chello.nl, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no, tgraf@suug.ch, James.Bottomley@steeleye.com, michaelc@cs.wisc.edu, akpm@linux-foundation.org, phillips@google.com
List-ID: <linux-mm.kvack.org>

> These suggestions conflict in the case of a large patchset: the second
> can't be met if you honor the first (more important suggestion IMHO).
> Unless you leave something out... and I can't see the value in leaving
> out the auxiliary consumers of the core changes.

They do not conflict.

If you say you're setting up infrastructure for a well defined
purpose, then each and every one of the patches can all stand on their
own just fine.  You can even post them one at a time and the review
process would work just fine.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Subject: Re: [ckrm-tech] Virtual NUMA machine and CKRM
In-Reply-To: Your message of "Fri, 27 May 2005 22:16:13 +0900 (JST)"
	<20050527.221613.78716667.taka@valinux.co.jp>
References: <20050527.221613.78716667.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Date: Wed, 01 Jun 2005 14:28:19 +0900
Message-Id: <1117603699.326265.4138.nullmailer@yamt.dyndns.org>
From: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: taka@valinux.co.jp
Cc: ckrm-tech@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

hi,

> Why don't you implement CKRM memory controller as virtual NUMA
> node.

i think that you need to describe what's a "virtual NUMA node" before
soliciting comments.

> I think what you want do is almost what NUMA code does, which
> restricts resources to use. If you define virtual NUMA node with
> some memory and some virtual CPUs, you can just assign target jobs
> to them.

because resource restrictions from numa and ckrm are very different,
i don't think there is a single effective structure for both of them.

YAMAMOTO Takashi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

Date: Mon, 28 Jul 2008 01:53:13 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2][-mm][resend] memcg limit change shrink usage.
Message-Id: <20080728015313.b4628537.akpm@linux-foundation.org>
In-Reply-To: <11498528.1217234602331.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080722014517.04e88306.akpm@linux-foundation.org>
	<20080714171154.e1cc9943.kamezawa.hiroyu@jp.fujitsu.com>
	<20080714171522.d1cd50e9.kamezawa.hiroyu@jp.fujitsu.com>
	<11498528.1217234602331.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kamezawa.hiroyu@jp.fujitsu.com
Cc: linux-mm@kvack.org, balbir@linux.vnet.ibm.com, xemul@openvz.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, 28 Jul 2008 17:43:22 +0900 (JST) kamezawa.hiroyu@jp.fujitsu.com wrote:

> >Guys, this is core Linux kernel, not some weekend hack project.  Please
> >work to make it as comprehensible and as maintainable as we possibly
> >can.
> >
> >Also, it is frequently a mistake for a callee to assume that the caller
> >can use GFP_KERNEL.  Often when we do this we end having to change the
> >interface so that the caller passes in the gfp_t.  As there's only one
> >caller I guess we can get away with it this time.  For now.
> >
> 
> Hmm, ok. will rework this and take gfp_t as an argument.

I don't think it's necessary, really.  I was just talking to myself ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

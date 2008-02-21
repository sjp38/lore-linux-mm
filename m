Date: Thu, 21 Feb 2008 15:49:16 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] Document huge memory/cache overhead of memory
 controller in Kconfig
Message-Id: <20080221154916.723fed49.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <47BC5211.6030102@linux.vnet.ibm.com>
References: <20080220122338.GA4352@basil.nowhere.org>
	<47BC2275.4060900@linux.vnet.ibm.com>
	<18364.16552.455371.242369@stoffel.org>
	<47BC4554.10304@linux.vnet.ibm.com>
	<Pine.LNX.4.64.0802201647060.26109@fbirervta.pbzchgretzou.qr>
	<18364.20755.798295.881259@stoffel.org>
	<47BC5211.6030102@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: John Stoffel <john@stoffel.org>, Jan Engelhardt <jengelh@computergmbh.de>, Andi Kleen <andi@firstfloor.org>, akpm@osdl.org, torvalds@osdl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 20 Feb 2008 21:45:13 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> > But for computers, limits is an expected and understood term, and for
> > filesystems it's quotas.  So in this case, I *still* think you should
> > be using the term "Memory Quota Controller" instead.  It just makes it
> > clearer to a larger audience what you mean.
> > 
> 
> Memory Quota sounds very confusing to me. Usually a quota implies limits, but in
> a true framework, one can also implement guarantees and shares.
> 
This "cgroup memory contoller" is called as "Memory Resource Contoller"
in my office ;)

How about Memory Resouce Contoller ?


-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

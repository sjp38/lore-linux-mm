Date: Thu, 18 Sep 2008 14:00:43 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] Remove cgroup member from struct page (v3)
Message-Id: <20080918140043.9ce73713.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <48D1D1C2.9060204@linux.vnet.ibm.com>
References: <200809091500.10619.nickpiggin@yahoo.com.au>
	<20080909141244.721dfd39.kamezawa.hiroyu@jp.fujitsu.com>
	<30229398.1220963412858.kamezawa.hiroyu@jp.fujitsu.com>
	<20080910012048.GA32752@balbir.in.ibm.com>
	<1221085260.6781.69.camel@nimitz>
	<48C84C0A.30902@linux.vnet.ibm.com>
	<1221087408.6781.73.camel@nimitz>
	<20080911103500.d22d0ea1.kamezawa.hiroyu@jp.fujitsu.com>
	<48C878AD.4040404@linux.vnet.ibm.com>
	<20080911105638.1581db90.kamezawa.hiroyu@jp.fujitsu.com>
	<20080917232826.GA19256@balbir.in.ibm.com>
	<20080917184008.92b7fc4c.akpm@linux-foundation.org>
	<48D1D1C2.9060204@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Nick Piggin <nickpiggin@yahoo.com.au>, hugh@veritas.com, menage@google.com, xemul@openvz.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 17 Sep 2008 20:57:54 -0700
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> Andrew Morton wrote:

> > someone somewhere decided that (Aa + Bb) / Cc < 1.0.  What are the values
> > of A, B and C and where did they come from? ;)
> > 
> > (IOW, your changelog is in the category "sucky", along with 90% of the others)
> 
> Yes, I agree, to be honest we discussed the reasons on the mailing list and
> those should go to the changelog. I'll do that in the next version of the
> patches. These are early RFC patches, but the changelog does suck.
> 
IIRC, (Aa + Bb) / Cc < 1.0 discussion was following.

Because we have to maintain pointer to page_cgroup in radix-tree (ZONE_NORMAL)

1. memory usage will increase when memory cgroup is enabled.
   The amount memory usage increase just depends on the height of radix-tree.

2. memory usage will decrease when memory cgroup is disabled.
   This saves 4bytes per 4096bytes. (on x86-32)

Thanks,
-Kame  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/3] memcg: fix account leak at failure of memsw
 acconting.
Date: Tue, 25 Jan 2011 08:07:26 +0100
Message-ID: <20110125070726.GA2217@cmpxchg.org>
References: <20110125145720.cd0cbe16.kamezawa.hiroyu@jp.fujitsu.com>
 <20110125150042.fa7a9a9a.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110125150042.fa7a9a9a.kamezawa.hiroyu@jp.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, stable@kernel.org
List-Id: linux-mm.kvack.org

On Tue, Jan 25, 2011 at 03:00:42PM +0900, KAMEZAWA Hiroyuki wrote:
> This is required for 2.6.36-stable and later.
> ==
> Commit 4b53433468c87794b523e4683fbd4e8e8aca1f63 removes
> a cancel of charge at case: 
> memory charge-> success.
> mem+swap charge-> failure.
> 
> This leaks usage of memory. Fix it.
> 
> This patch is required for stable tree since 2.6.36.
> 
> CC: stable@kernel.org
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Reviewed-by: Johannes Weiner <hannes@cmpxchg.org>

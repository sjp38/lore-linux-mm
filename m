Date: Tue, 26 Feb 2008 10:26:27 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 00/15] memcg: fixes and cleanups
Message-Id: <20080226102627.3ab92247.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0802252327490.27067@blonde.site>
References: <Pine.LNX.4.64.0802252327490.27067@blonde.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Hirokazu Takahashi <taka@valinux.co.jp>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 25 Feb 2008 23:34:04 +0000 (GMT)
Hugh Dickins <hugh@veritas.com> wrote:

> Here's my series of fifteen mem_cgroup patches against 2.6.25-rc3:
> fixes to bugs I've found and cleanups made on the way to those fixes.
> I believe we'll want these in 2.6.25-rc4.  Mostly they're what was
> included in the rollup I posted on Friday, but 05/15 and 15/15 fix
> (pre-existing) page migration and force_empty bugs I found after that.
> I'm not at all happy with force_empty, 15/15 discusses it a little.
> 

Hi, thank you.

I'll work on this.

Regards,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

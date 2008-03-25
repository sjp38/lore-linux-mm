Date: Tue, 25 Mar 2008 15:30:20 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] fix spurious EBUSY on memory cgroup removal
Message-Id: <20080325153020.d9179428.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080324225309.0a1ab8ec.akpm@linux-foundation.org>
References: <20080325054713.948EF1E92EC@siro.lan>
	<20080324225309.0a1ab8ec.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: YAMAMOTO Takashi <yamamoto@valinux.co.jp>, balbir@linux.vnet.ibm.com, containers@lists.osdl.org, linux-mm@kvack.org, minoura@valinux.co.jp
List-ID: <linux-mm.kvack.org>

On Mon, 24 Mar 2008 22:53:09 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Tue, 25 Mar 2008 14:47:13 +0900 (JST) yamamoto@valinux.co.jp (YAMAMOTO Takashi) wrote:
> 
> > [ resending with To: akpm.  Andrew, can you include this in -mm tree? ]
> 
> Shouldn't it be in 2.6.25?
> 
I think this should be.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

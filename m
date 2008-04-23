Date: Wed, 23 Apr 2008 11:50:41 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcg: remove redundant initialization in
 mem_cgroup_create()
Message-Id: <20080423115041.c918091d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <480E9E52.4080905@cn.fujitsu.com>
References: <480E9E52.4080905@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 23 Apr 2008 10:26:26 +0800
Li Zefan <lizf@cn.fujitsu.com> wrote:

> *mem has been zeroed, that means mem->info has already
> been filled with 0.
> 
maybe my mistake :(

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

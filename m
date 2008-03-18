Date: Tue, 18 Mar 2008 19:25:41 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/4] Block I/O tracking
Message-Id: <20080318192541.54cc1a7d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080318.182508.103216251.taka@valinux.co.jp>
References: <20080318.182251.93858044.taka@valinux.co.jp>
	<20080318.182508.103216251.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, containers@lists.linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Tue, 18 Mar 2008 18:25:08 +0900 (JST)
Hirokazu Takahashi <taka@valinux.co.jp> wrote:

> Hi,
> 
> This patch splits the cgroup memory subsystem into two parts.
> One is for tracking which cgroup which pages and the other is
> for controlling how much amount of memory should be assigned to
> each cgroup.
> 
> With this patch, you can use the page tracking mechanism even if
> the memory subsystem is off.
> 
> Signed-off-by: Hirokazu Takahashi <taka@valinux.co.jp>
> 
I think current my work, radix-tree page cgroup will help this work.
It creates page_cgroup.h and page_cgroup.c.
Patches are posted last week to the mm-list.(And now rewriting..)
Please let me know if you have requests.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

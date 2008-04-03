From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [-mm] Make the memory controller more desktop responsive
Date: Thu, 3 Apr 2008 18:43:51 +0900
Message-ID: <20080403184351.42de4f56.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080403093253.8944.10168.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760084AbYDCJjX@vger.kernel.org>
In-Reply-To: <20080403093253.8944.10168.sendpatchset@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>
List-Id: linux-mm.kvack.org

On Thu, 03 Apr 2008 15:02:53 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> This patch makes the memory controller more responsive on my desktop.
> 
> Here is what the patch does
> 
> 1. Reduces the number of retries to 2. We had 5 earlier, since we
>    were controlling swap cache as well. We pushed data from mappings
>    to swap cache and we needed additional passes to clear out the cache.

Hmm, what this change improves ?
I don't want to see OOM.

> 2. It sets all cached pages as inactive. We were by default marking
>    all pages as active, thus forcing us to go through two passes for
>    reclaiming pages
Agreed.

> 3. Removes congestion_wait(), since we already have that logic in
>    do_try_to_free_pages()
> 
Agreed.

Thanks,
-Kame

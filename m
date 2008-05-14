Message-ID: <482AE934.7060204@openvz.org>
Date: Wed, 14 May 2008 17:29:24 +0400
From: Pavel Emelyanov <xemul@openvz.org>
MIME-Version: 1.0
Subject: Re: [-mm][PATCH 2/4] Setup the memrlimit controller (v4)
References: <20080514130904.24440.23486.sendpatchset@localhost.localdomain> <20080514130926.24440.77703.sendpatchset@localhost.localdomain>
In-Reply-To: <20080514130926.24440.77703.sendpatchset@localhost.localdomain>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Balbir Singh wrote:
> This patch sets up the rlimit cgroup controller. It adds the basic create,
> destroy and populate functionality. The user interface provided is very
> similar to the memory resource controller. The rlimit controller can be
> enhanced easily in the future to control mlocked pages.
> 
> Changelog v3->v4
> 
> 1. Use PAGE_ALIGN()
> 2. Rename rlimit to memrlimit
> 
> 
> Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>

Acked-by: Pavel Emelyanov <xemul@openvz.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Wed, 9 Apr 2008 08:34:49 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [-mm] Disable the memory controller by default (v3)
Message-Id: <20080409083449.d6a63259.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080408114613.8165.69030.sendpatchset@localhost.localdomain>
References: <20080408114613.8165.69030.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: andi@firstfloor.org, Andrew Morton <akpm@linux-foundation.org>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pavel Emelianov <xemul@openvz.org>, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Tue, 08 Apr 2008 17:16:13 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> 
> 
> Changelog v1
> 
> 1. Split cgroup_disable into cgroup_disable and cgroup_enable
> 2. Remove cgroup_toggle
> 
> Due to the overhead of the memory controller. The
> memory controller is now disabled by default. This patch adds cgroup_enable.
> 
> If everyone agrees on this approach and likes it, should we push this
> into 2.6.25?
> 
> Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> ---
> 
Thank you for this boot option.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [-mm] Disable the memory controller by default (v2)
Date: Tue, 8 Apr 2008 10:09:02 +0900
Message-ID: <20080408100902.fcd9d911.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080407130215.26565.81715.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758817AbYDHBE0@vger.kernel.org>
In-Reply-To: <20080407130215.26565.81715.sendpatchset@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: andi@firstfloor.org, Andrew Morton <akpm@linux-foundation.org>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pavel Emelianov <xemul@openvz.org>, hugh@veritas.com
List-Id: linux-mm.kvack.org

On Mon, 07 Apr 2008 18:32:15 +0530
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
BTW, how the user can know which controllers are on/off at default ?
All controllers are off ?

Thanks,
-Kame

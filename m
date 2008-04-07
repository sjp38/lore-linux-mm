From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [-mm] Disable the memory controller by default
Date: Mon, 7 Apr 2008 14:03:40 +0200
Message-ID: <20080407120340.GB16647@one.firstfloor.org>
References: <20080407115137.24124.59692.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758131AbYDGL7c@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080407115137.24124.59692.sendpatchset@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: andi@firstfloor.org, Andrew Morton <akpm@linux-foundation.org>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pavel Emelianov <xemul@openvz.org>, hugh@veritas.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-Id: linux-mm.kvack.org

On Mon, Apr 07, 2008 at 05:21:37PM +0530, Balbir Singh wrote:
> 
> 
> Due to the overhead of the memory controller. The
> memory controller is now disabled by default. This patch changes
> cgroup_disable to cgroup_toggle, so that each controller can decide
> whether it wants to be enabled/disabled by default.
> 
> If everyone agrees on this approach and likes it, should we push this
> into 2.6.25?

First I like the change to make it disabled by default.

I don't think "toggle" is good semantics for a user visible switch
because that changes the meaning when the kernel default changes
(which it will likely once the current default overhead is fixed)

It should be rather: cgroup=on/off 

-Andi

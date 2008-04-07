From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [-mm] Disable the memory controller by default
Date: Mon, 07 Apr 2008 17:33:17 +0530
Message-ID: <47FA0D85.201@linux.vnet.ibm.com>
References: <20080407115137.24124.59692.sendpatchset@localhost.localdomain> <20080407120340.GB16647@one.firstfloor.org>
Reply-To: balbir@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758204AbYDGMEs@vger.kernel.org>
In-Reply-To: <20080407120340.GB16647@one.firstfloor.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pavel Emelianov <xemul@openvz.org>, hugh@veritas.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-Id: linux-mm.kvack.org

Andi Kleen wrote:
> On Mon, Apr 07, 2008 at 05:21:37PM +0530, Balbir Singh wrote:
>>
>> Due to the overhead of the memory controller. The
>> memory controller is now disabled by default. This patch changes
>> cgroup_disable to cgroup_toggle, so that each controller can decide
>> whether it wants to be enabled/disabled by default.
>>
>> If everyone agrees on this approach and likes it, should we push this
>> into 2.6.25?
> 
> First I like the change to make it disabled by default.
> 
> I don't think "toggle" is good semantics for a user visible switch
> because that changes the meaning when the kernel default changes
> (which it will likely once the current default overhead is fixed)
> 
> It should be rather: cgroup=on/off 
> 

The boot control options apply to all controllers and we want to allow
controllers to decide whether they should be turned on or off. With sufficient
documentation support in Documentation/kernel-parameters.txt, don't you think we
can expect this to work as the user intended?

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

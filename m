From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [-mm] Disable the memory controller by default (v2)
Date: Tue, 08 Apr 2008 08:01:21 +0530
Message-ID: <47FAD8F9.7070308@linux.vnet.ibm.com>
References: <20080407130215.26565.81715.sendpatchset@localhost.localdomain> <20080408100902.fcd9d911.kamezawa.hiroyu@jp.fujitsu.com>
Reply-To: balbir@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758640AbYDHCc6@vger.kernel.org>
In-Reply-To: <20080408100902.fcd9d911.kamezawa.hiroyu@jp.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: andi@firstfloor.org, Andrew Morton <akpm@linux-foundation.org>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pavel Emelianov <xemul@openvz.org>, hugh@veritas.com
List-Id: linux-mm.kvack.org

KAMEZAWA Hiroyuki wrote:
> On Mon, 07 Apr 2008 18:32:15 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
>>
>> Changelog v1
>>
>> 1. Split cgroup_disable into cgroup_disable and cgroup_enable
>> 2. Remove cgroup_toggle
>>
>> Due to the overhead of the memory controller. The
>> memory controller is now disabled by default. This patch adds cgroup_enable.
>>
>> If everyone agrees on this approach and likes it, should we push this
>> into 2.6.25?
>>
>> Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
>> ---
> BTW, how the user can know which controllers are on/off at default ?
> All controllers are off ?
> 

/proc/cgroups has an enabled field (fourth one). That should show what is
enabled/disabled. I've also documented it in
Documentation/kernel-parameters.txt. I intend to enable the memory controller
again, once we bring down the overhead.

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

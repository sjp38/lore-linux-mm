From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][-mm] Add an owner to the mm_struct (v4)
Date: Thu, 03 Apr 2008 10:02:25 +0530
Message-ID: <47F45DD9.4030004@linux.vnet.ibm.com>
References: <20080401124312.23664.64616.sendpatchset@localhost.localdomain> <47F3D62E.4070808@linux.vnet.ibm.com> <6599ad830804021253y6bf3b37y9bf1167b63c32e70@mail.gmail.com> <47F4577E.5060905@linux.vnet.ibm.com> <6599ad830804022110h2090f3efg7c6173df8185679e@mail.gmail.com>
Reply-To: balbir@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759958AbYDCEcy@vger.kernel.org>
In-Reply-To: <6599ad830804022110h2090f3efg7c6173df8185679e@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Paul Menage <menage@google.com>
Cc: Pavel Emelianov <xemul@openvz.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-Id: linux-mm.kvack.org

Paul Menage wrote:
> On Wed, Apr 2, 2008 at 9:05 PM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>>  I checked to see that cgroup_exit is called after mm_update_new_owner(). We call
>>  mm_update_new_owner() from exit_mm(). I did not check for current->cgroups !=
>>  new_owner->cgroups, since I did not want to limit the callbacks.
> 
> No cgroup subsystem should be concerned about mm ownership changes
> between tasks in the same cgroup. So I think that's a valid and useful
> optimization.
> 

Hmm. probably.. I'll do that check. Let me post v5 with these changes

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

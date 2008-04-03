From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [-mm] Add an owner to the mm_struct (v7)
Date: Thu, 03 Apr 2008 23:41:51 +0530
Message-ID: <47F51DE7.7010204@linux.vnet.ibm.com>
References: <20080403174433.26356.42121.sendpatchset@localhost.localdomain> <6599ad830804031058l1e2a7ad9p56cff47dca738d79@mail.gmail.com>
Reply-To: balbir@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760476AbYDCSM3@vger.kernel.org>
In-Reply-To: <6599ad830804031058l1e2a7ad9p56cff47dca738d79@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Paul Menage <menage@google.com>
Cc: Pavel Emelianov <xemul@openvz.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-Id: linux-mm.kvack.org

Paul Menage wrote:
> On Thu, Apr 3, 2008 at 10:44 AM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>>  +
>>  +       /*
>>  +        * If there are other users of the mm and the owner (us) is exiting
>>  +        * we need to find a new owner to take on the responsibility.
>>  +        * When we use thread groups (CLONE_THREAD), the thread group
>>  +        * leader is kept around in zombie state, even after it exits.
>>  +        * delay_group_leader() ensures that if the group leader is around
>>  +        * we need not select a new owner.
>>  +        */
> 
> Hmm, is this new check for delay_group_leader() safe? Won't we have
> called exit_cgroup() by this point, and hence be reassigned to the
> root cgroup? And so mm->owner->cgroups won't point to the right place?
> 

cgroup_exit() comes in much later after exit_mm(). Moreover delay_group_leader()
is a function that checks to see if

We are the group leader and the thread group is not empty.

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [-mm] Disable the memory controller by default
Date: Mon, 07 Apr 2008 17:46:59 +0530
Message-ID: <47FA10BB.9000305@linux.vnet.ibm.com>
References: <20080407115137.24124.59692.sendpatchset@localhost.localdomain> <20080407120340.GB16647@one.firstfloor.org> <47FA0D85.201@linux.vnet.ibm.com> <2f11576a0804070516r185bff87t449c315bd7787c7e@mail.gmail.com>
Reply-To: balbir@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758347AbYDGMSX@vger.kernel.org>
In-Reply-To: <2f11576a0804070516r185bff87t449c315bd7787c7e@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: KOSAKI Motohiro <m-kosaki@ceres.dti.ne.jp>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pavel Emelianov <xemul@openvz.org>, hugh@veritas.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-Id: linux-mm.kvack.org

KOSAKI Motohiro wrote:
>>  The boot control options apply to all controllers and we want to allow
>>  controllers to decide whether they should be turned on or off. With sufficient
>>  documentation support in Documentation/kernel-parameters.txt, don't you think we
>>  can expect this to work as the user intended?
> 
> 2 parameter is wrong?
> 
>        cgroup_disable= [KNL] Disable a particular controller
>                        Format: {name of the controller(s) to disable}
>        cgroup_enable= [KNL] Enable a particular controller
>                        Format: {name of the controller(s) to enable}
> 

No, it is not all bad. That can be done, but we need to guard against a usage like

cgroup_disable=memory cgroup_enable=memory

The user will probably get what he/she deserves for it.

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

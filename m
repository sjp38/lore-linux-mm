From: "KOSAKI Motohiro" <m-kosaki@ceres.dti.ne.jp>
Subject: Re: [-mm] Disable the memory controller by default
Date: Mon, 7 Apr 2008 21:16:39 +0900
Message-ID: <2f11576a0804070516r185bff87t449c315bd7787c7e@mail.gmail.com>
References: <20080407115137.24124.59692.sendpatchset@localhost.localdomain>
	 <20080407120340.GB16647@one.firstfloor.org>
	 <47FA0D85.201@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758131AbYDGMQt@vger.kernel.org>
In-Reply-To: <47FA0D85.201@linux.vnet.ibm.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: balbir@linux.vnet.ibm.com
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pavel Emelianov <xemul@openvz.org>, hugh@veritas.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-Id: linux-mm.kvack.org

>  The boot control options apply to all controllers and we want to allow
>  controllers to decide whether they should be turned on or off. With sufficient
>  documentation support in Documentation/kernel-parameters.txt, don't you think we
>  can expect this to work as the user intended?

2 parameter is wrong?

       cgroup_disable= [KNL] Disable a particular controller
                       Format: {name of the controller(s) to disable}
       cgroup_enable= [KNL] Enable a particular controller
                       Format: {name of the controller(s) to enable}

e.g.
user specified cgroup_enable=mem.
if default value is disable, it mean turn to enable.
if default value is enable,  it is meaningless param.

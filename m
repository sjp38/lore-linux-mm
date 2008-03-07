Date: Fri, 7 Mar 2008 01:04:12 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] Add cgroup support for enabling controllers at boot time
 (v2)
In-Reply-To: <20080307085735.25567.314.sendpatchset@localhost.localdomain>
Message-ID: <alpine.DEB.1.00.0803070102020.4693@chino.kir.corp.google.com>
References: <20080307085735.25567.314.sendpatchset@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Paul Menage <menage@google.com>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelianov <xemul@openvz.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Randy Dunlap <randy.dunlap@oracle.com>
List-ID: <linux-mm.kvack.org>

On Fri, 7 Mar 2008, Balbir Singh wrote:

> diff -puN Documentation/kernel-parameters.txt~cgroup_disable Documentation/kernel-parameters.txt
> --- linux-2.6.25-rc4/Documentation/kernel-parameters.txt~cgroup_disable	2008-03-07 14:26:16.000000000 +0530
> +++ linux-2.6.25-rc4-balbir/Documentation/kernel-parameters.txt	2008-03-07 14:26:16.000000000 +0530
> @@ -383,6 +383,10 @@ and is between 256 and 4096 characters. 
>  	ccw_timeout_log [S390]
>  			See Documentation/s390/CommonIO for details.
>  
> +	cgroup_disable= [KNL] Disable a particular controller
> +			Format: {name of the controller(s) to disable}
> +				{Currently supported controllers - "memory"}
> +
>  	checkreqprot	[SELINUX] Set initial checkreqprot flag value.
>  			Format: { "0" | "1" }
>  			See security/selinux/Kconfig help text.

It would probably be helpful to mention in the documentation that the 
names of the subsystems must now be delimited by commas.

 [ I also find it very helpful to add randy.dunlap@oracle.com to the cc
   list for any patch touching Documentation ]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

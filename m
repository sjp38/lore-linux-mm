From: kamezawa.hiroyu@jp.fujitsu.com
Message-ID: <28343987.1209914862098.kamezawa.hiroyu@jp.fujitsu.com>
Date: Mon, 5 May 2008 00:27:42 +0900 (JST)
Subject: Re: Re: [-mm][PATCH 0/4] Add rlimit controller to cgroups (v3)
In-Reply-To: <23630056.1209914669637.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
References: <23630056.1209914669637.kamezawa.hiroyu@jp.fujitsu.com>
 <20080503213726.3140.68845.sendpatchset@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kamezawa.hiroyu@jp.fujitsu.com
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

>   "+This controller framework is designed to be extensible to control any
>   "+resource limit (memory related) with little effort."
>   memory only ? Ok, all you want to do is related to memory, but someone
>   may want to limit RLIMIT_CPU by group or RLIMIT_CORE by group or....
>   (I have no plan but they seems useful.;)
...RLIMIT_MEMLOCK is in my want-to-do-list ;)

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

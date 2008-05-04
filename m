From: kamezawa.hiroyu@jp.fujitsu.com
Message-ID: <23630056.1209914669637.kamezawa.hiroyu@jp.fujitsu.com>
Date: Mon, 5 May 2008 00:24:29 +0900 (JST)
Subject: Re: [-mm][PATCH 0/4] Add rlimit controller to cgroups (v3)
In-Reply-To: <20080503213726.3140.68845.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
References: <20080503213726.3140.68845.sendpatchset@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

>
>
>This is the third version of the address space control patches. These
>patches are against 2.6.25-mm1  and have been tested using KVM in SMP mode,
>both with and without the config enabled.
>
>The first patch adds the user interface. The second patch fixes the
>cgroup mm_owner_changed callback to pass the task struct, so that
>accounting can be adjusted on owner changes. The thrid patch adds accounting
>and control. The fourth patch updates documentation.
>
>An earlier post of the patchset can be found at
>http://lwn.net/Articles/275143/
>
>This patch is built on top of the mm owner patches and utilizes that feature
>to virtually group tasks by mm_struct.
>
>Reviews, Comments?
>

I can't read the whole patch deeply now but this new concept "rlimit-controlle
r" seems make sense to me.

At quick glance, I have some thoughts.

1. kerner/rlimit_cgroup.c is better for future expansion.
2. why 
   "+This controller framework is designed to be extensible to control any
   "+resource limit (memory related) with little effort."
   memory only ? Ok, all you want to do is related to memory, but someone
   may want to limit RLIMIT_CPU by group or RLIMIT_CORE by group or....
   (I have no plan but they seems useful.;)
   So, could you add design hint of rlimit contoller to the documentation ?
   
3. Rleated to 2. Showing what kind of "rlimit" params are supported by
   cgroup will be good.

I don't think you have to implement all things at once. Staring from
"only RLIMIT_AS is supported now" is good. Someone will expand it if
he needs. But showing basic view of "gerenal purpose rlimit contoller" in _doc
ument_ or _comments_ or _codes_ is a good thing to do.

If you don't want to provide RLIMIT feature other than address space,
it's better to avoid using the name of RLIMIT. It's confusing.

Thanks,
-Kame





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

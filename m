Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f175.google.com (mail-ie0-f175.google.com [209.85.223.175])
	by kanga.kvack.org (Postfix) with ESMTP id EAE156B027B
	for <linux-mm@kvack.org>; Tue, 14 Jul 2015 19:48:26 -0400 (EDT)
Received: by iebmu5 with SMTP id mu5so22388823ieb.1
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 16:48:26 -0700 (PDT)
Received: from mail-ig0-x22a.google.com (mail-ig0-x22a.google.com. [2607:f8b0:4001:c05::22a])
        by mx.google.com with ESMTPS id b199si2104030ioe.42.2015.07.14.16.48.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Jul 2015 16:48:26 -0700 (PDT)
Received: by igcqs7 with SMTP id qs7so94388382igc.0
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 16:48:26 -0700 (PDT)
Date: Tue, 14 Jul 2015 16:48:24 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: cpu_hotplug vs oom_notify_list: possible circular locking
 dependency detected
In-Reply-To: <20150714232943.GW3717@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.10.1507141647531.16182@chino.kir.corp.google.com>
References: <20150712105634.GA11708@marcin-Inspiron-7720> <alpine.DEB.2.10.1507141508590.16182@chino.kir.corp.google.com> <20150714232943.GW3717@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="397176738-422283606-1436917705=:16182"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: =?UTF-8?Q?Marcin_=C5=9Alusarz?= <marcin.slusarz@gmail.com>, Tejun Heo <tj@kernel.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--397176738-422283606-1436917705=:16182
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT

On Tue, 14 Jul 2015, Paul E. McKenney wrote:

> commit a1992f2f3b8e174d740a8f764d0d51344bed2eed
> Author: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> Date:   Tue Jul 14 16:24:14 2015 -0700
> 
>     rcu: Don't disable CPU hotplug during OOM notifiers
>     
>     RCU's rcu_oom_notify() disables CPU hotplug in order to stabilize the
>     list of online CPUs, which it traverses.  However, this is completely
>     pointless because smp_call_function_single() will quietly fail if invoked
>     on an offline CPU.  Because the count of requests is incremented in the
>     rcu_oom_notify_cpu() function that is remotely invoked, everything works
>     nicely even in the face of concurrent CPU-hotplug operations.
>     
>     Furthermore, in recent kernels, invoking get_online_cpus() from an OOM
>     notifier can result in deadlock.  This commit therefore removes the
>     call to get_online_cpus() and put_online_cpus() from rcu_oom_notify().
>     
>     Reported-by: Marcin A?lusarz <marcin.slusarz@gmail.com>
>     Reported-by: David Rientjes <rientjes@google.com>
>     Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

Acked-by: David Rientjes <rientjes@google.com>
--397176738-422283606-1436917705=:16182--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

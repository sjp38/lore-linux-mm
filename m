Received: by wa-out-1112.google.com with SMTP id j37so1954413waf.22
        for <linux-mm@kvack.org>; Tue, 28 Oct 2008 23:55:06 -0700 (PDT)
Message-ID: <2f11576a0810282355t7a5b5cc1id7442229ded104b1@mail.gmail.com>
Date: Wed, 29 Oct 2008 15:55:06 +0900
From: "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [discuss][memcg] oom-kill extension
In-Reply-To: <alpine.DEB.1.10.0810282206260.10159@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20081029113826.cc773e21.kamezawa.hiroyu@jp.fujitsu.com>
	 <4907E1B4.6000406@linux.vnet.ibm.com>
	 <20081029140012.fff30bce.kamezawa.hiroyu@jp.fujitsu.com>
	 <alpine.DEB.1.10.0810282206260.10159@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, balbir@linux.vnet.ibm.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, "menage@google.com" <menage@google.com>, Marcelo Tosatti <mtosatti@redhat.com>
List-ID: <linux-mm.kvack.org>

> There was a patchset from February that added /dev/mem_notify to warn
> userspace of low or out of memory conditions:
>
>        http://marc.info/?l=linux-kernel&m=120257050719077
>        http://marc.info/?l=linux-kernel&m=120257050719087
>        http://marc.info/?l=linux-kernel&m=120257062719234
>        http://marc.info/?l=linux-kernel&m=120257071219327
>        http://marc.info/?l=linux-kernel&m=120257071319334
>        http://marc.info/?l=linux-kernel&m=120257080919488
>        http://marc.info/?l=linux-kernel&m=120257081019497
>        http://marc.info/?l=linux-kernel&m=120257096219705
>        http://marc.info/?l=linux-kernel&m=120257096319717
>
> Perhaps this idea can simply be reworked for the memory controller or
> standalone cgroup?

Very sorry.

I know my laziness is wrong.
I have made split-lru effort give priority more than other awhile.

So I'll restart user-land notify effort soon.

Paul, I strongly interest to your implementation.
Could you post your notify patch?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

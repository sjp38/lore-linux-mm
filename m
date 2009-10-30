Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id F22C76B0073
	for <linux-mm@kvack.org>; Fri, 30 Oct 2009 09:59:40 -0400 (EDT)
Received: by bwz7 with SMTP id 7so3817864bwz.6
        for <linux-mm@kvack.org>; Fri, 30 Oct 2009 06:59:38 -0700 (PDT)
Message-ID: <4AEAF145.3010801@gmail.com>
Date: Fri, 30 Oct 2009 14:59:33 +0100
From: =?UTF-8?B?VmVkcmFuIEZ1cmHEjQ==?= <vedran.furac@gmail.com>
Reply-To: vedran.furac@gmail.com
MIME-Version: 1.0
Subject: Re: Memory overcommit
References: <hav57c$rso$1@ger.gmane.org> <4ADE3121.6090407@gmail.com> <20091026105509.f08eb6a3.kamezawa.hiroyu@jp.fujitsu.com> <4AE5CB4E.4090504@gmail.com> <20091027122213.f3d582b2.kamezawa.hiroyu@jp.fujitsu.com> <Pine.LNX.4.64.0910271843510.11372@sister.anvils> <alpine.DEB.2.00.0910271351140.9183@chino.kir.corp.google.com> <4AE78B8F.9050201@gmail.com> <alpine.DEB.2.00.0910271723180.17615@chino.kir.corp.google.com> <4AE792B8.5020806@gmail.com> <alpine.DEB.2.00.0910272047430.8988@chino.kir.corp.google.com> <20091028135519.805c4789.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.0910272205200.7507@chino.kir.corp.google.com> <20091028150536.674abe68.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.0910272311001.15462@chino.kir.corp.google.com> <20091028152015.3d383cd6.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.0910290136000.11476@chino.kir.corp.google.com> <4AE97861.1070902@gmail.com> <alpine.DEB.2.00.0910291248480.2276@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.0910291248480.2276@chino.kir.corp.google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, minchan.kim@gmail.com, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

David Rientjes wrote:

> On Thu, 29 Oct 2009, Vedran Furac wrote:
> 
>> But then you should rename OOM killer to TRIPK:
>> Totally Random Innocent Process Killer
>>
> 
> The randomness here is the order of the child list when the oom killer 
> selects a task, based on the badness score, and then tries to kill a child 
> with a different mm before the parent.
> 
> The problem you identified in http://pastebin.com/f3f9674a0, however, is a 
> forkbomb issue where the badness score should never have been so high for 
> kdeinit4 compared to "test".  That's directly proportional to adding the 
> scores of all disjoint child total_vm values into the badness score for 
> the parent and then killing the children instead.

Could you explain me why ntpd invoked oom killer? Its parent is init. Or
syslog-ng?

> That's the problem, not using total_vm as a baseline.  Replacing that with 
> rss is not going to solve the issue and reducing the user's ability to 
> specify a rough oom priority from userspace is simply not an option.

OK then, if you have a solution, I would be glad to test your patch. I
won't care much if you don't change total_vm as a baseline. Just make
random killing history.

Regards,

Vedran

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 1A8F76B0089
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 14:56:46 -0500 (EST)
Subject: Re: Memory overcommit
Received: by mail-bw0-f215.google.com with SMTP id 7so7287751bwz.6
        for <linux-mm@kvack.org>; Mon, 02 Nov 2009 11:56:45 -0800 (PST)
Message-ID: <4AEF3979.9090306@gmail.com>
Date: Mon, 02 Nov 2009 20:56:41 +0100
From: =?UTF-8?B?VmVkcmFuIEZ1cmHEjQ==?= <vedran.furac@gmail.com>
Reply-To: vedran.furac@gmail.com
MIME-Version: 1.0
References: <hav57c$rso$1@ger.gmane.org> <hb2cfu$r08$2@ger.gmane.org> <20091014135119.e1baa07f.kamezawa.hiroyu@jp.fujitsu.com> <4ADE3121.6090407@gmail.com> <20091026105509.f08eb6a3.kamezawa.hiroyu@jp.fujitsu.com> <4AE5CB4E.4090504@gmail.com> <20091027122213.f3d582b2.kamezawa.hiroyu@jp.fujitsu.com> <Pine.LNX.4.64.0910271843510.11372@sister.anvils> <alpine.DEB.2.00.0910271351140.9183@chino.kir.corp.google.com> <4AE78B8F.9050201@gmail.com> <alpine.DEB.2.00.0910271723180.17615@chino.kir.corp.google.com> <4AE792B8.5020806@gmail.com> <alpine.DEB.2.00.0910272047430.8988@chino.kir.corp.google.com> <4AE846E8.1070303@gmail.com> <alpine.DEB.2.00.0910281307370.23279@chino.kir.corp.google.com> <4AE9068B.7030504@gmail.com> <alpine.DEB.2.00.0910290132320.11476@chino.kir.corp.google.com> <4AE97618.6060607@gmail.com> <alpine.DEB.2.00.0910291225460.27732@chino.kir.corp.google.com> <4AEAEFDD.5060009@gmail.com> <alpine.DEB.2.00.0910301232180.1090@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.0910301232180.1090@chino.kir.corp.google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, minchan.kim@gmail.com, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

David Rientjes wrote:

> On Fri, 30 Oct 2009, Vedran Furac wrote:
> 
>> Well, you are kernel hacker, not me. You know how linux mm works much
>> more than I do. I just reported a, what I think is a big problem, which
>> needs to be solved ASAP (2.6.33).
> 
> The oom killer heuristics have not been changed recently, why is this 
> suddenly a problem that needs to be immediately addressed?  The heuristics 
> you've been referring to have been used for at least three years.

It isn't "suddenly a problem", but only a problem, big long time
problem. If it is three years old, then it should have been addressed
asap three years ago (and we would not need to talk about it now,
hopefully).

> However, I don't think we can simply change the baseline (like the rss 
> change which has been added to -mm (??)) and consider it a major 
> improvement when it severely impacts how system administrators are able to 
> tune the badness heuristic from userspace via /proc/pid/oom_adj.  I'm sure 
> you'd agree that user input is important in this matter and so that we 
> should maximize that ability rather than make it more difficult.  That's 
> my main criticism of the suggestions thus far (and, sorry, but I have to 
> look out for production server interests here: you can't take away our 
> ability to influence oom badness scoring just because other simple 
> heuristics may be more understandable).
> 
> What would be better, and what I think we'll end up with, is a root 
> selectable heuristic so that production servers and desktop machines can 
> use different heuristics to make oom kill selections.  We already have 
> /proc/sys/vm/oom_kill_allocating_task which I added 1-2 years ago to 
> address concerns specifically of SGI and their enormously long tasklist 
> scans.  This would be variation on that idea and would include different 
> simplistic behaviors (such as always killing the most memory hogging task, 
> killing the most recently started task by the same uid, etc), and leave 
> the default heuristic much the same as currently.

OK, agreed. Did you take a look at the set of patches Kame sent today?

Regards,

Vedran

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

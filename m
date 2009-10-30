Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 5BC086B004D
	for <linux-mm@kvack.org>; Fri, 30 Oct 2009 10:41:17 -0400 (EDT)
Received: by bwz7 with SMTP id 7so3865058bwz.6
        for <linux-mm@kvack.org>; Fri, 30 Oct 2009 07:41:15 -0700 (PDT)
Message-ID: <4AEAFB08.8050305@gmail.com>
Date: Fri, 30 Oct 2009 15:41:12 +0100
From: =?UTF-8?B?VmVkcmFuIEZ1cmHEjQ==?= <vedran.furac@gmail.com>
Reply-To: vedran.furac@gmail.com
MIME-Version: 1.0
Subject: Re: Memory overcommit
References: <alpine.DEB.2.00.0910271723180.17615@chino.kir.corp.google.com> <4AE792B8.5020806@gmail.com> <alpine.DEB.2.00.0910272047430.8988@chino.kir.corp.google.com> <4AE846E8.1070303@gmail.com> <alpine.DEB.2.00.0910281307370.23279@chino.kir.corp.google.com> <4AE9068B.7030504@gmail.com> <alpine.DEB.2.00.0910290132320.11476@chino.kir.corp.google.com> <4AE97618.6060607@gmail.com> <alpine.DEB.2.00.0910291225460.27732@chino.kir.corp.google.com> <4AEAEFDD.5060009@gmail.com> <20091030141250.GQ9640@random.random>
In-Reply-To: <20091030141250.GQ9640@random.random>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: David Rientjes <rientjes@google.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, minchan.kim@gmail.com, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli wrote:

> On Fri, Oct 30, 2009 at 02:53:33PM +0100, Vedran FuraA? wrote:
>> % free -m
>>           total       used       free     shared    buffers     cached
>> Mem:      3458        3429         29          0        102       1119
>> -/+ buffers/cache:    2207       1251
>>
>> There's plenty of memory available. Shouldn't cache be automatically
>> dropped (this question was in my original mail, hence the subject)?
> 
> This is not about cache, cache amount is physical, this about
> virtual amount that can only go in ram or swap (at any later time,
> current time is irrelevant) vs "ram + swap".

Oh... so this is because apps "reserve" (Committed_AS?) more then they
currently need.

> In short add more swap if
> you don't like overcommit and check grep Commit /proc/meminfo in case
> this is accounting bug...

A the time of "malloc: Cannot allocate memory":

CommitLimit:     3364440 kB
Committed_AS:    3240200 kB

So probably everything is ok (and free is misleading). Overcommit is
unfortunately necessary if I want to be able to use all my memory.

Btw. http://www.redhat.com/advice/tips/meminfo.html says Committed_AS is
a (gu)estimate. Hope it is a good (not to high) guesstimate. :)

Regards,

Vedran

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

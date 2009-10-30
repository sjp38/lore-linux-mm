Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 0DCC86B0073
	for <linux-mm@kvack.org>; Fri, 30 Oct 2009 10:12:59 -0400 (EDT)
Date: Fri, 30 Oct 2009 15:12:50 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: Memory overcommit
Message-ID: <20091030141250.GQ9640@random.random>
References: <alpine.DEB.2.00.0910271723180.17615@chino.kir.corp.google.com>
 <4AE792B8.5020806@gmail.com>
 <alpine.DEB.2.00.0910272047430.8988@chino.kir.corp.google.com>
 <4AE846E8.1070303@gmail.com>
 <alpine.DEB.2.00.0910281307370.23279@chino.kir.corp.google.com>
 <4AE9068B.7030504@gmail.com>
 <alpine.DEB.2.00.0910290132320.11476@chino.kir.corp.google.com>
 <4AE97618.6060607@gmail.com>
 <alpine.DEB.2.00.0910291225460.27732@chino.kir.corp.google.com>
 <4AEAEFDD.5060009@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <4AEAEFDD.5060009@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Vedran =?utf-8?B?RnVyYcSN?= <vedran.furac@gmail.com>
Cc: David Rientjes <rientjes@google.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, minchan.kim@gmail.com, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, Oct 30, 2009 at 02:53:33PM +0100, Vedran FuraA? wrote:
> % free -m
>           total       used       free     shared    buffers     cached
> Mem:      3458        3429         29          0        102       1119
> -/+ buffers/cache:    2207       1251
> 
> There's plenty of memory available. Shouldn't cache be automatically
> dropped (this question was in my original mail, hence the subject)?

This is not about cache, cache amount is physical, this about
virtual amount that can only go in ram or swap (at any later time,
current time is irrelevant) vs "ram + swap". In short add more swap if
you don't like overcommit and check grep Commit /proc/meminfo in case
this is accounting bug...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

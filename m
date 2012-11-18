Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id D8AFF6B006E
	for <linux-mm@kvack.org>; Sun, 18 Nov 2012 17:55:39 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id fa10so3176550pad.14
        for <linux-mm@kvack.org>; Sun, 18 Nov 2012 14:55:39 -0800 (PST)
Date: Sun, 18 Nov 2012 14:55:36 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [3.6 regression?] THP + migration/compaction livelock (I
 think)
In-Reply-To: <20121117001826.GC9816@offline.be>
Message-ID: <alpine.DEB.2.00.1211181453550.5080@chino.kir.corp.google.com>
References: <CALCETrVgbx-8Ex1Q6YgEYv-Oxjoa1oprpsQE-Ww6iuwf7jFeGg@mail.gmail.com> <alpine.DEB.2.00.1211131507370.17623@chino.kir.corp.google.com> <CALCETrU=7+pk_rMKKuzgW1gafWfv6v7eQtVw3p8JryaTkyVQYQ@mail.gmail.com> <alpine.DEB.2.00.1211131530020.17623@chino.kir.corp.google.com>
 <20121114100154.GI8218@suse.de> <20121114132940.GA13196@offline.be> <alpine.DEB.2.00.1211141342460.13515@chino.kir.corp.google.com> <20121115011449.GA20858@offline.be> <20121117001826.GC9816@offline.be>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marc Duponcheel <marc@offline.be>
Cc: Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, 17 Nov 2012, Marc Duponcheel wrote:

> # echo always >/sys/kernel/mm/transparent_hugepage/enabled
> # while [ 1 ]
>   do
>    sleep 10
>    date
>    echo = vmstat
>    egrep "(thp|compact)" /proc/vmstat
>    echo = khugepaged stack
>    cat /proc/501/stack
>  done > /tmp/49361.xxxx
> # emerge icedtea
> (where 501 = pidof khugepaged)
> 
> for xxxx = base = 3.6.6
> and xxxx = test = 3.6.6 + diff you provided
> 
> I attach 
>  /tmp/49361.base.gz
> and
>  /tmp/49361.test.gz
> 
> Note:
> 
>  with xxx=base, I could see
>   PID USER      PR  NI  VIRT  RES  SHR S  %CPU %MEM     TIME+ COMMAND
>  8617 root      20   0 3620m  41m  10m S 988.3  0.5   6:19.06 javac
>     1 root      20   0  4208  588  556 S   0.0  0.0   0:03.25 init
>  already during configure and I needed to kill -9 javac
> 
>  with xxx=test, I could see
>   PID USER      PR  NI  VIRT  RES  SHR S  %CPU %MEM     TIME+ COMMAND
> 9275 root      20   0 2067m 474m  10m S 304.2  5.9   0:32.81 javac
>  710 root       0 -20     0    0    0 S   0.3  0.0   0:01.07 kworker/0:1H
>  later when processing >700 java files
> 
> Also note that with xxx=test compact_blocks_moved stays 0
> 

Sounds good!  Andy, have you had the opportunity to try to reproduce your 
issue with the backports that Mel listed?  I think he'll be considering 
asking for some of these to be backported for a future stable release so 
any input you can provide would certainly be helpful.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

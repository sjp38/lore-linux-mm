Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id BA0DA6B0044
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 14:30:31 -0400 (EDT)
Received: by bwz24 with SMTP id 24so12885bwz.10
        for <linux-mm@kvack.org>; Tue, 27 Oct 2009 11:30:28 -0700 (PDT)
Message-ID: <4AE73C40.8070307@gmail.com>
Date: Tue, 27 Oct 2009 19:30:24 +0100
From: =?UTF-8?B?VmVkcmFuIEZ1cmHEjQ==?= <vedran.furac@gmail.com>
Reply-To: vedran.furac@gmail.com
MIME-Version: 1.0
Subject: Re: Memory overcommit
References: <hav57c$rso$1@ger.gmane.org>	 <20091013120840.a844052d.kamezawa.hiroyu@jp.fujitsu.com>	 <hb2cfu$r08$2@ger.gmane.org>	 <20091014135119.e1baa07f.kamezawa.hiroyu@jp.fujitsu.com>	 <4ADE3121.6090407@gmail.com>	 <20091026105509.f08eb6a3.kamezawa.hiroyu@jp.fujitsu.com>	 <4AE5CB4E.4090504@gmail.com>	 <20091027122213.f3d582b2.kamezawa.hiroyu@jp.fujitsu.com>	 <4AE72A0D.9070804@gmail.com> <2f11576a0910271102g60dcdd1dj8f3df213bc64a51d@mail.gmail.com>
In-Reply-To: <2f11576a0910271102g60dcdd1dj8f3df213bc64a51d@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, hugh.dickins@tiscali.co.uk, akpm@linux-foundation.org, rientjes@google.com
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro wrote:

>>> I attached a scirpt for checking oom_score of all exisiting process.
>>> (oom_score is a value used for selecting "bad" processs.")
>>> please run if you have time.
>> 96890   21463   VirtualBox // OK
>> 118615  11144   kded4 // WRONG
>> 127455  11158   knotify4 // WRONG
>> 132198  1       init // WRONG
>> 133940  11151   ksmserver // WRONG
>> 134109  11224   audacious2 // Audio player, maybe
>> 145476  21503   VirtualBox // OK
>> 174939  11322   icedove-bin // thunderbird, maybe
>> 178015  11223   akregator // rss reader, maybe
>> 201043  22672   krusader  // WRONG
>> 212609  11187   krunner // WRONG
>> 256911  24252   test // culprit, malloced 1GB
>> 1750371 11318   run-mozilla.sh // tiny, parent of firefox threads
>> 2044902 11141   kdeinit4 // tiny, parent of most KDE apps
> 
> Verdran, I made alternative improvement idea. Can you please mesure
> badness score
> on your system?
> Maybe your culprit process take biggest badness value.

Thanks, I'll test it during the week. But note that not every user
reboots its computer everyday. I, for example, usually have it up for
days. And when it comes to my laptop - weeks, as I just suspend it when
I don't use it. Maybe the best way is to combine two patches. Also, you
and others could also test these patches. It is not only my kernel that
behaves strange. :)

> Note: this patch change time related thing. So, please drink a cup of
> coffee before mesurement.
> small rest time makes correct test result.

OK. :)

Regards,

Vedran

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

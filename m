Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 3220B900086
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 21:48:17 -0400 (EDT)
Received: from wpaz21.hot.corp.google.com (wpaz21.hot.corp.google.com [172.24.198.85])
	by smtp-out.google.com with ESMTP id p3G1mF60008176
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 18:48:15 -0700
Received: from gwb19 (gwb19.prod.google.com [10.200.2.19])
	by wpaz21.hot.corp.google.com with ESMTP id p3G1mAcD030483
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 18:48:14 -0700
Received: by gwb19 with SMTP id 19so1633539gwb.18
        for <linux-mm@kvack.org>; Fri, 15 Apr 2011 18:48:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1104151602270.2738@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1104131132240.5563@chino.kir.corp.google.com>
	<20110414090310.07FF.A69D9226@jp.fujitsu.com>
	<alpine.DEB.2.00.1104131740280.16515@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1104141316450.20747@chino.kir.corp.google.com>
	<alpine.LSU.2.00.1104151528050.4774@sister.anvils>
	<alpine.DEB.2.00.1104151602270.2738@chino.kir.corp.google.com>
Date: Fri, 15 Apr 2011 18:48:09 -0700
Message-ID: <BANLkTi=BD0PRHPGqmc1KrxwX2cyPdjSc5w@mail.gmail.com>
Subject: Re: [patch v3] oom: replace PF_OOM_ORIGIN with toggling oom_score_adj
From: Hugh Dickins <hughd@google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Matt Fleming <matt@console-pimps.org>, linux-mm@kvack.org

On Fri, Apr 15, 2011 at 4:03 PM, David Rientjes <rientjes@google.com> wrote=
:
> On Fri, 15 Apr 2011, Hugh Dickins wrote:
>
>> This makes good sense (now you're using MAX instead of MIN!),
>> but may I helatedly ask you to change the name test_set_oom_score_adj()
>> to replace_oom_score_adj()? =C2=A0test_set means a bitflag operation to =
me.
>>
>
> Does replace_oom_score_adj() imply that it will be returning the old valu=
e
> of oom_score_adj like test_set_oom_score_adj() does?

I can easily imagine an implementation of "replace_oom_score_adj"
which does not return the old value: so no, that name does not imply
that it will be returning the old value.  But since it does return
something, it's quite reasonable that what it returns is the old
value.

Whereas "test_set_oom_score_adj" tends to imply that it will set the
oom_score_adj only if it's currently zero.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

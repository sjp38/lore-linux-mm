Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 82E756B0011
	for <linux-mm@kvack.org>; Tue, 24 May 2011 05:20:53 -0400 (EDT)
Received: by qwa26 with SMTP id 26so4661023qwa.14
        for <linux-mm@kvack.org>; Tue, 24 May 2011 02:20:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4DDB75D8.1000804@jp.fujitsu.com>
References: <4DD61F80.1020505@jp.fujitsu.com>
	<4DD6207E.1070300@jp.fujitsu.com>
	<BANLkTinaHki1oA4O3+FsoPDtFTLfqwRadA@mail.gmail.com>
	<4DDB0FB2.9050300@jp.fujitsu.com>
	<BANLkTinKm=m8zdPGN0Trpy4HtEFyxMYzPA@mail.gmail.com>
	<4DDB711B.8010408@jp.fujitsu.com>
	<BANLkTik5tXv+k9tk2egXgmBRzcBD5Avjkw@mail.gmail.com>
	<4DDB75D8.1000804@jp.fujitsu.com>
Date: Tue, 24 May 2011 18:20:51 +0900
Message-ID: <BANLkTime4C8nk0TBOfd2NT4mEEtLN6ZYaQ@mail.gmail.com>
Subject: Re: [PATCH 4/5] oom: don't kill random process
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, caiqian@redhat.com, rientjes@google.com, hughd@google.com, kamezawa.hiroyu@jp.fujitsu.com, oleg@redhat.com

On Tue, May 24, 2011 at 6:09 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>>>> Hmm, If I understand your code correctly, unprivileged process can get
>>>> a score 1 by 3% bonus.
>>>
>>> 3% bonus is for privileged process. :)
>>
>> OMG. Typo.
>> Anyway, my point is following as.
>> If chose_point is 1, it means root bonus is rather big. Right?
>> If is is, your patch does second loop with completely ignore of bonus
>> for root privileged process.
>> My point is that let's not ignore bonus completely. Instead of it,
>> let's recalculate 1.5% for example.
>
> 1) unpriviledged process can't get score 1 (because at least a process ne=
ed one
> =C2=A0 anon, one file and two or more ptes).
> 2) then, score=3D1 mean all processes in the system are privileged. thus =
decay won't help.
>
> IOW, never happen privileged and unprivileged score in this case.

I am blind. Thanks for open my eyes, KOSAKI.


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

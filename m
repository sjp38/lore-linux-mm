Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 50C6D6B005D
	for <linux-mm@kvack.org>; Thu, 31 May 2012 03:10:08 -0400 (EDT)
Received: by ghbf11 with SMTP id f11so715443ghb.8
        for <linux-mm@kvack.org>; Thu, 31 May 2012 00:10:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1205302351510.25774@chino.kir.corp.google.com>
References: <1338260214-21919-1-git-send-email-gaofeng@cn.fujitsu.com>
 <alpine.DEB.2.00.1205301433490.9716@chino.kir.corp.google.com>
 <4FC6B68C.2070703@jp.fujitsu.com> <CAHGf_=pFbsy4FO_UNu6O1-KyTd6O=pkmR8=3EGuZB5Reu3Vb9w@mail.gmail.com>
 <4FC6BC3E.5010807@jp.fujitsu.com> <alpine.DEB.2.00.1205301737530.25774@chino.kir.corp.google.com>
 <4FC6C111.2060108@jp.fujitsu.com> <alpine.DEB.2.00.1205301831270.25774@chino.kir.corp.google.com>
 <4FC6D881.4090706@jp.fujitsu.com> <alpine.DEB.2.00.1205302156090.25774@chino.kir.corp.google.com>
 <4FC70355.70805@jp.fujitsu.com> <alpine.DEB.2.00.1205302314190.25774@chino.kir.corp.google.com>
 <4FC70E5E.1010003@gmail.com> <alpine.DEB.2.00.1205302325500.25774@chino.kir.corp.google.com>
 <4FC711A5.4090003@gmail.com> <alpine.DEB.2.00.1205302351510.25774@chino.kir.corp.google.com>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Thu, 31 May 2012 03:09:45 -0400
Message-ID: <CAHGf_=qVDVT6VW2j9gE3bQKwizW24iivrDryiCKoxVu4m_fWKw@mail.gmail.com>
Subject: Re: [PATCH] meminfo: show /proc/meminfo base on container's memcg
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Gao feng <gaofeng@cn.fujitsu.com>, hannes@cmpxchg.org, mhocko@suse.cz, bsingharora@gmail.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, containers@lists.linux-foundation.org

On Thu, May 31, 2012 at 2:56 AM, David Rientjes <rientjes@google.com> wrote=
:
> On Thu, 31 May 2012, KOSAKI Motohiro wrote:
>
>> > This is tangent to the discussion, we need to revisit why an applicati=
on
>> > other than a daemon managing a set of memcgs would ever need to know t=
he
>> > information in /proc/meminfo. =A0No use-case was ever presented in the
>> > changelog and its not clear how this is at all relevant. =A0So before
>> > changing the kernel, please describe how this actually matters in a re=
al-
>> > world scenario.
>>
>> Huh? Don't you know a meanings of a namespace ISOLATION? isolation mean,
>> isolated container shouldn't be able to access global information. If yo=
u
>> want to lean container/namespace concept, tasting openvz or solaris cont=
ainer
>> is a good start.
>
> As I said, LXC and namespace isolation is a tangent to the discussion of
> faking the /proc/meminfo for the memcg context of a thread.

Because of, /proc/meminfo affect a lot of libraries behavior. So, it's not =
only
application issue. If you can't rewrite _all_ of userland assets, fake memi=
nfo
can't be escaped. Again see alternative container implementation.


>
>> But anyway, I dislike current implementaion. So, I NAK this patch too.
>>
>
> I'm glad you reached that conclusion, but I think you did so for a much
> different (although unspecified) reason.
>
> Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 490516B004F
	for <linux-mm@kvack.org>; Wed, 25 Jan 2012 17:48:39 -0500 (EST)
Received: by qadc11 with SMTP id c11so1337227qad.14
        for <linux-mm@kvack.org>; Wed, 25 Jan 2012 14:48:38 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120124134750.de5f31ee.kamezawa.hiroyu@jp.fujitsu.com>
References: <20120113173001.ee5260ca.kamezawa.hiroyu@jp.fujitsu.com>
	<20120113174019.8dff3fc1.kamezawa.hiroyu@jp.fujitsu.com>
	<CALWz4izasaECifCYoRXL45x1YXYzACC=kUHQivnGZKRH+ySjuw@mail.gmail.com>
	<20120124134750.de5f31ee.kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 25 Jan 2012 14:48:38 -0800
Message-ID: <CALWz4ixtMxHKJP3ZbOHK26B7Q9V=7M6h-giadbNWp+QQ6hjo-A@mail.gmail.com>
Subject: Re: [RFC] [PATCH 3/7 v2] memcg: remove PCG_MOVE_LOCK flag from pc->flags
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, cgroups@vger.kernel.org, "bsingharora@gmail.com" <bsingharora@gmail.com>

On Mon, Jan 23, 2012 at 8:47 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Mon, 23 Jan 2012 14:02:48 -0800
> Ying Han <yinghan@google.com> wrote:
>
>> On Fri, Jan 13, 2012 at 12:40 AM, KAMEZAWA Hiroyuki
>> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> >
>> > From 1008e84d94245b1e7c4d237802ff68ff00757736 Mon Sep 17 00:00:00 2001
>> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> > Date: Thu, 12 Jan 2012 15:53:24 +0900
>> > Subject: [PATCH 3/7] memcg: remove PCG_MOVE_LOCK flag from pc->flags.
>> >
>> > PCG_MOVE_LOCK bit is used for bit spinlock for avoiding race between
>> > memcg's account moving and page state statistics updates.
>> >
>> > Considering page-statistics update, very hot path, this lock is
>> > taken only when someone is moving account (or PageTransHuge())
>> > And, now, all moving-account between memcgroups (by task-move)
>> > are serialized.
>>
>> This might be a side question, can you clarify the serialization here?
>> Does it mean that we only allow one task-move at a time system-wide?
>>
>
> current implementation has that limit by mutex.

ah, thanks. that is the cgroup_mutex lock which serializes
mem_cgroup_move_charge() from move task.

--Ying

>
> Thanks,
> -Kame
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

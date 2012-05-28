Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 3CE996B0082
	for <linux-mm@kvack.org>; Mon, 28 May 2012 13:22:49 -0400 (EDT)
Received: by dakp5 with SMTP id p5so5452303dak.14
        for <linux-mm@kvack.org>; Mon, 28 May 2012 10:22:48 -0700 (PDT)
Subject: Re: [PATCH] memcg: remove the unnecessary MEM_CGROUP_STAT_DATA
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
From: Chen Baozi <baozich@gmail.com>
In-Reply-To: <20120528133918.GA22185@tiehlicka.suse.cz>
Date: Tue, 29 May 2012 01:22:41 +0800
Content-Transfer-Encoding: quoted-printable
Message-Id: <B23B2709-F70C-4B47-80CC-FBC3AA40A907@gmail.com>
References: <1337933501-3985-1-git-send-email-baozich@gmail.com> <20120528133918.GA22185@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>


On May 28, 2012, at 9:39 PM, Michal Hocko wrote:

> On Fri 25-05-12 16:11:41, Chen Baozi wrote:
>> Since MEM_CGROUP_ON_MOVE has been removed, it comes to be redudant
>> to hold MEM_CGROUP_STAT_DATA to mark the end of data requires
>> synchronization.
>=20
> A similar patch has been already posted by Johannes 2 weeks ago
> (http://www.gossamer-threads.com/lists/linux/kernel/1535888) and it
> should appear in -next soonish.
Oh, I see, Thanks for informing.

Baozi

>=20
>>=20
>> Signed-off-by: Chen Baozi <baozich@gmail.com>
>> ---
>> mm/memcontrol.c |    3 +--
>> 1 files changed, 1 insertions(+), 2 deletions(-)
>>=20
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index f342778..446ca94 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -88,7 +88,6 @@ enum mem_cgroup_stat_index {
>> 	MEM_CGROUP_STAT_RSS,	   /* # of pages charged as anon rss */
>> 	MEM_CGROUP_STAT_FILE_MAPPED,  /* # of pages charged as file rss =
*/
>> 	MEM_CGROUP_STAT_SWAPOUT, /* # of pages, swapped out */
>> -	MEM_CGROUP_STAT_DATA, /* end of data requires synchronization */
>> 	MEM_CGROUP_STAT_NSTATS,
>> };
>>=20
>> @@ -2139,7 +2138,7 @@ static void mem_cgroup_drain_pcp_counter(struct =
mem_cgroup *memcg, int cpu)
>> 	int i;
>>=20
>> 	spin_lock(&memcg->pcp_counter_lock);
>> -	for (i =3D 0; i < MEM_CGROUP_STAT_DATA; i++) {
>> +	for (i =3D 0; i < MEM_CGROUP_STAT_NSTATS; i++) {
>> 		long x =3D per_cpu(memcg->stat->count[i], cpu);
>>=20
>> 		per_cpu(memcg->stat->count[i], cpu) =3D 0;
>> --=20
>> 1.7.1
>>=20
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Fight unfair telecom internet charges in Canada: sign =
http://stopthemeter.ca/
>> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>=20
> --=20
> Michal Hocko
> SUSE Labs
> SUSE LINUX s.r.o.
> Lihovarska 1060/12
> 190 00 Praha 9   =20
> Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

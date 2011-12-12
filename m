Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 15B7A6B01A8
	for <linux-mm@kvack.org>; Mon, 12 Dec 2011 12:58:17 -0500 (EST)
Received: by qadc16 with SMTP id c16so873306qad.14
        for <linux-mm@kvack.org>; Mon, 12 Dec 2011 09:58:16 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20111212105134.GA18789@cmpxchg.org>
References: <1323476120-8964-1-git-send-email-yinghan@google.com>
	<20111212105134.GA18789@cmpxchg.org>
Date: Mon, 12 Dec 2011 09:58:15 -0800
Message-ID: <CALWz4izKscc=JbpEHpxLHg+SLw1MjZ6WZ14OoxOi9i-ZBFOw5A@mail.gmail.com>
Subject: Re: [PATCH] memcg: fix a typo in documentation
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pavel Emelyanov <xemul@openvz.org>, linux-mm@kvack.org

On Mon, Dec 12, 2011 at 2:51 AM, Johannes Weiner <hannes@cmpxchg.org> wrote=
:
> On Fri, Dec 09, 2011 at 04:15:20PM -0800, Ying Han wrote:
>> A tiny typo on mapped_file stat.
>>
>> Signed-off-by: Ying Han <yinghan@google.com>
>> ---
>> =A0Documentation/cgroups/memory.txt | =A0 =A02 +-
>> =A01 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/me=
mory.txt
>> index 070c016..c0f409e 100644
>> --- a/Documentation/cgroups/memory.txt
>> +++ b/Documentation/cgroups/memory.txt
>> @@ -410,7 +410,7 @@ hierarchical_memsw_limit - # of bytes of memory+swap=
 limit with regard to
>>
>> =A0total_cache =A0 =A0 =A0 =A0 =A0- sum of all children's "cache"
>> =A0total_rss =A0 =A0 =A0 =A0 =A0 =A0- sum of all children's "rss"
>> -total_mapped_file =A0 =A0- sum of all children's "cache"
>> +total_mapped_file =A0 =A0- sum of all children's "mapped_file"
>> =A0total_mlock =A0 =A0 =A0 =A0 =A0- sum of all children's "mlock"
>> =A0total_pgpgin =A0 =A0 =A0 =A0 - sum of all children's "pgpgin"
>> =A0total_pgpgout =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0- sum of all children's =
"pgpgout"
>
> Your fix obviously makes sense, but the line is still incorrect: it's
> not just the sum of all children but that of the full hierarchy
> starting with the consulted memcg. =A0It includes that memcg's local
> counter as well. =A0Aside from that, this all seems awefully redundant.
>
> How about this on top?
>
> ---
> From: Johannes Weiner <hannes@cmpxchg.org>
> Subject: [patch] Documentation: memcg: future proof hierarchical statisti=
cs
> =A0documentation
>
> The hierarchical versions of per-memcg counters in memory.stat are all
> calculated the same way and are all named total_<counter>.
>
> Documenting the pattern is easier for maintenance than listing each
> counter twice.
>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
> =A0Documentation/cgroups/memory.txt | =A0 15 ++++-----------
> =A01 files changed, 4 insertions(+), 11 deletions(-)
>
> diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/mem=
ory.txt
> index 06eb6d9..a858675 100644
> --- a/Documentation/cgroups/memory.txt
> +++ b/Documentation/cgroups/memory.txt
> @@ -404,17 +404,10 @@ hierarchical_memory_limit - # of bytes of memory li=
mit with regard to hierarchy
> =A0hierarchical_memsw_limit - # of bytes of memory+swap limit with regard=
 to
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0hierarchy under which memo=
ry cgroup is.
>
> -total_cache =A0 =A0 =A0 =A0 =A0 =A0- sum of all children's "cache"
> -total_rss =A0 =A0 =A0 =A0 =A0 =A0 =A0- sum of all children's "rss"
> -total_mapped_file =A0 =A0 =A0- sum of all children's "mapped_file"
> -total_pgpgin =A0 =A0 =A0 =A0 =A0 - sum of all children's "pgpgin"
> -total_pgpgout =A0 =A0 =A0 =A0 =A0- sum of all children's "pgpgout"
> -total_swap =A0 =A0 =A0 =A0 =A0 =A0 - sum of all children's "swap"
> -total_inactive_anon =A0 =A0- sum of all children's "inactive_anon"
> -total_active_anon =A0 =A0 =A0- sum of all children's "active_anon"
> -total_inactive_file =A0 =A0- sum of all children's "inactive_file"
> -total_active_file =A0 =A0 =A0- sum of all children's "active_file"
> -total_unevictable =A0 =A0 =A0- sum of all children's "unevictable"
> +total_<counter> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0- # hierarchical version =
of <counter>, which in
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 addition to the cgroup's ow=
n value includes the
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sum of all hierarchical chi=
ldren's values of
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 <counter>, i.e. total_cache
>
> =A0# The following additional stats are dependent on CONFIG_DEBUG_VM.

Yes, make sense to me :)

Acked-by: Ying Han <yinghan@google.com>

--Ying

>
> --
> 1.7.7.3
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

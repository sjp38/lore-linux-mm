Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 4E1326B004D
	for <linux-mm@kvack.org>; Wed, 25 Jan 2012 13:54:08 -0500 (EST)
Received: by qcsg1 with SMTP id g1so2269066qcs.14
        for <linux-mm@kvack.org>; Wed, 25 Jan 2012 10:54:07 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120124084133.GD1660@cmpxchg.org>
References: <20120119161445.b3a8a9d2.kamezawa.hiroyu@jp.fujitsu.com>
	<CALWz4ixufzgi2kDRgTMAzty-S2AKMmPfqdGc1sBRNFJxf-WTAQ@mail.gmail.com>
	<20120124084133.GD1660@cmpxchg.org>
Date: Wed, 25 Jan 2012 10:54:06 -0800
Message-ID: <CALWz4iyoRCFG9=aiySFzQb3HsM33yW7tZB4N6xee6qUvO6L2-g@mail.gmail.com>
Subject: Re: [PATCH] memcg: remove unnecessary thp check at page stat accounting
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>

On Tue, Jan 24, 2012 at 12:41 AM, Johannes Weiner <hannes@cmpxchg.org> wrot=
e:
> On Mon, Jan 23, 2012 at 12:11:11PM -0800, Ying Han wrote:
>> On Wed, Jan 18, 2012 at 11:14 PM, KAMEZAWA Hiroyuki
>> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> > Thank you very much for reviewing previous RFC series.
>> > This is a patch against memcg-devel and linux-next (can by applied wit=
hout HUNKs).
>> >
>> > =3D=3D
>> >
>> > From 64641b360839b029bb353fbd95f7554cc806ed05 Mon Sep 17 00:00:00 2001
>> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> > Date: Thu, 12 Jan 2012 16:08:33 +0900
>> > Subject: [PATCH] memcg: remove unnecessary thp check in mem_cgroup_upd=
ate_page_stat()
>> >
>> > commit 58b318ecf(memcg-devel)
>> > =A0 =A0memcg: make mem_cgroup_split_huge_fixup() more efficient
>> > removes move_lock_page_cgroup() in thp-split path.
>> >
>> > So, We do not have to check PageTransHuge in mem_cgroup_update_page_st=
at
>> > and fallback into the locked accounting because both move charge and t=
hp
>> > split up are done with compound_lock so they cannot race. update vs.
>> > move is protected by the mem_cgroup_stealed sufficiently.
>>
>> Sorry, i don't see we changed the "move charge" to "move account" ?
>
> move_account() moves charges. =A0IMO, it's the function that is a
> misnomer and "moving charges" is less ambiguous since we account
> several different things in the memory controller.

Hmm, that works then.

Acked-by: Ying Han<yinghan@google.com>

--Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

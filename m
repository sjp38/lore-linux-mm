Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 6466F6B0087
	for <linux-mm@kvack.org>; Wed,  5 Jan 2011 21:49:38 -0500 (EST)
Received: by iyj17 with SMTP id 17so15565470iyj.14
        for <linux-mm@kvack.org>; Wed, 05 Jan 2011 18:49:36 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110106100923.24b1dd12.nishimura@mxp.nes.nec.co.jp>
References: <20110105130020.e2a854e4.nishimura@mxp.nes.nec.co.jp>
	<20110105115840.GD4654@cmpxchg.org>
	<20110106100923.24b1dd12.nishimura@mxp.nes.nec.co.jp>
Date: Thu, 6 Jan 2011 11:49:36 +0900
Message-ID: <AANLkTi=rp=WZa7PP4V6anU0SQ3BM-RJQwiDu1fJuoDig@mail.gmail.com>
Subject: Re: [BUGFIX][PATCH] memcg: fix memory migration of shmem swapcache
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Jan 6, 2011 at 10:09 AM, Daisuke Nishimura
<nishimura@mxp.nes.nec.co.jp> wrote:
> On Wed, 5 Jan 2011 12:58:40 +0100
> Johannes Weiner <hannes@cmpxchg.org> wrote:
>
>> On Wed, Jan 05, 2011 at 01:00:20PM +0900, Daisuke Nishimura wrote:
>> > In current implimentation, mem_cgroup_end_migration() decides whether =
the page
>> > migration has succeeded or not by checking "oldpage->mapping".
>> >
>> > But if we are tring to migrate a shmem swapcache, the page->mapping of=
 it is
>> > NULL from the begining, so the check would be invalid.
>> > As a result, mem_cgroup_end_migration() assumes the migration has succ=
eeded
>> > even if it's not, so "newpage" would be freed while it's not uncharged=

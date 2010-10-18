Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 09F776B00B3
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 01:52:20 -0400 (EDT)
Received: by iwn1 with SMTP id 1so834404iwn.14
        for <linux-mm@kvack.org>; Sun, 17 Oct 2010 22:52:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20101018143108.4e0e5299.kamezawa.hiroyu@jp.fujitsu.com>
References: <20101013121527.8ec6a769.kamezawa.hiroyu@jp.fujitsu.com>
	<20101013121829.c3320944.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTingNmxT6ww_VB_K=rjsgR+dHANLnyNkwV1Myvnk@mail.gmail.com>
	<20101018093533.abd4c8ee.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTikt+kq2LHZNSJAN3EQwYALdYtGuOAXfVghN-7oY@mail.gmail.com>
	<20101018143108.4e0e5299.kamezawa.hiroyu@jp.fujitsu.com>
Date: Mon, 18 Oct 2010 14:52:19 +0900
Message-ID: <AANLkTimpVWwH=znGkG8zEPBcYxq-+UR+7mN29f-RK7d=@mail.gmail.com>
Subject: Re: [RFC][PATCH 3/3] alloc contig pages with migration.
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, Oct 18, 2010 at 2:31 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Mon, 18 Oct 2010 14:18:52 +0900
> Minchan Kim <minchan.kim@gmail.com> wrote:
>> >
>> >> > + *
>> >> > + * Search an area of @size in the physical memory map and checks w=
heter
>> >>
>> >> Typo
>> >> whether
>> >>
>> >> > + * we can create a contigous free space. If it seems possible, try=
 to
>> >> > + * create contigous space with page migration. If no_search=3D=3Dt=
rue, we just try
>> >> > + * to allocate [hint, hint+size) range of pages as contigous block=

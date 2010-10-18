Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id D328B6B00CA
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 01:18:54 -0400 (EDT)
Received: by iwn1 with SMTP id 1so799346iwn.14
        for <linux-mm@kvack.org>; Sun, 17 Oct 2010 22:18:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20101018093533.abd4c8ee.kamezawa.hiroyu@jp.fujitsu.com>
References: <20101013121527.8ec6a769.kamezawa.hiroyu@jp.fujitsu.com>
	<20101013121829.c3320944.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTingNmxT6ww_VB_K=rjsgR+dHANLnyNkwV1Myvnk@mail.gmail.com>
	<20101018093533.abd4c8ee.kamezawa.hiroyu@jp.fujitsu.com>
Date: Mon, 18 Oct 2010 14:18:52 +0900
Message-ID: <AANLkTikt+kq2LHZNSJAN3EQwYALdYtGuOAXfVghN-7oY@mail.gmail.com>
Subject: Re: [RFC][PATCH 3/3] alloc contig pages with migration.
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, Oct 18, 2010 at 9:35 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> > + * @node: =A0 =A0 =A0 the node from which memory is allocated. "-1" m=
eans anywhere.
>> > + * @no_search: if true, "hint" is not a hint, requirement.
>>
>> As I said previous, how about "strict" or "ALLOC_FIXED" like MAP_FIXED?
>>
>
> If "range" is an argument, ALLOC_FIXED is not necessary. I'll add "range"=

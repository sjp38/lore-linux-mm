Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1FFAB6B21F2
	for <linux-mm@kvack.org>; Tue, 20 Nov 2018 16:02:53 -0500 (EST)
Received: by mail-it1-f200.google.com with SMTP id z195-v6so4242743itb.7
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 13:02:53 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 138sor38297417ita.17.2018.11.20.13.02.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 20 Nov 2018 13:02:52 -0800 (PST)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (1.0)
Subject: Re: [PATCH -next 1/2] mm/memfd: make F_SEAL_FUTURE_WRITE seal more robust
From: Andy Lutomirski <luto@amacapital.net>
In-Reply-To: <20181120204710.GB22801@google.com>
Date: Tue, 20 Nov 2018 14:02:49 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <F8E28229-C99E-4711-982B-5B5DE0F70F16@amacapital.net>
References: <20181120052137.74317-1-joel@joelfernandes.org> <CALCETrXgBENat=5=7EuU-ttQ-YSXT+ifjLGc=hpJ=unRgSsndw@mail.gmail.com> <20181120183926.GA124387@google.com> <20181121070658.011d576d@canb.auug.org.au> <469B80CB-D982-4802-A81D-95AC493D7E87@amacapital.net> <20181120204710.GB22801@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joel Fernandes <joel@joelfernandes.org>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, Andy Lutomirski <luto@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Jann Horn <jannh@google.com>, Khalid Aziz <khalid.aziz@oracle.com>, Linux API <linux-api@vger.kernel.org>, "open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, marcandre.lureau@redhat.com, Matthew Wilcox <willy@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>, Shuah Khan <shuah@kernel.org>


> On Nov 20, 2018, at 1:47 PM, Joel Fernandes <joel@joelfernandes.org> wrote=
:
>=20
>> On Tue, Nov 20, 2018 at 01:33:18PM -0700, Andy Lutomirski wrote:
>>=20
>>> On Nov 20, 2018, at 1:07 PM, Stephen Rothwell <sfr@canb.auug.org.au> wro=
te:
>>>=20
>>> Hi Joel,
>>>=20
>>>>> On Tue, 20 Nov 2018 10:39:26 -0800 Joel Fernandes <joel@joelfernandes.=
org> wrote:
>>>>>=20
>>>>> On Tue, Nov 20, 2018 at 07:13:17AM -0800, Andy Lutomirski wrote:
>>>>> On Mon, Nov 19, 2018 at 9:21 PM Joel Fernandes (Google)
>>>>> <joel@joelfernandes.org> wrote: =20
>>>>>>=20
>>>>>> A better way to do F_SEAL_FUTURE_WRITE seal was discussed [1] last we=
ek
>>>>>> where we don't need to modify core VFS structures to get the same
>>>>>> behavior of the seal. This solves several side-effects pointed out by=

>>>>>> Andy [2].
>>>>>>=20
>>>>>> [1] https://lore.kernel.org/lkml/20181111173650.GA256781@google.com/
>>>>>> [2] https://lore.kernel.org/lkml/69CE06CC-E47C-4992-848A-66EB23EE6C74=
@amacapital.net/
>>>>>>=20
>>>>>> Suggested-by: Andy Lutomirski <luto@kernel.org>
>>>>>> Fixes: 5e653c2923fd ("mm: Add an F_SEAL_FUTURE_WRITE seal to memfd") =
=20
>>>>>=20
>>>>> What tree is that commit in?  Can we not just fold this in? =20
>>>>=20
>>>> It is in linux-next. Could we keep both commits so we have the history?=

>>>=20
>>> Well, its in Andrew's mmotm, so its up to him.
>>>=20
>>>=20
>>=20
>> Unless mmotm is more magical than I think, the commit hash in your fixed
>> tag is already nonsense. mmotm gets rebased all the time, and is only
>> barely a git tree.
>=20
> I wouldn't go so far to call it nonsense. It was a working patch, it just d=
id
> things differently. Your help with improving the patch is much appreciated=
.

I=E2=80=99m not saying the patch is nonsense =E2=80=94 I=E2=80=99m saying th=
e *hash* may be nonsense. akpm uses a bunch of .patch files and all kinds of=
 crazy scripts, and the mmotm.git tree is not stable at all.

>=20
> I am Ok with whatever Andrew wants to do, if it is better to squash it wit=
h
> the original, then I can do that and send another patch.
>=20
>=20

=46rom experience, Andrew will food in fixups on request :)=

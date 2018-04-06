Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0D49F6B0003
	for <linux-mm@kvack.org>; Thu,  5 Apr 2018 23:08:03 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id 25-v6so15521273oir.13
        for <linux-mm@kvack.org>; Thu, 05 Apr 2018 20:08:03 -0700 (PDT)
Received: from tyo161.gate.nec.co.jp (tyo161.gate.nec.co.jp. [114.179.232.161])
        by mx.google.com with ESMTPS id g1-v6si2927031otc.319.2018.04.05.20.08.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Apr 2018 20:08:01 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH] mm: shmem: enable thp migration (Re: [PATCH v1] mm:
 consider non-anonymous thp as unmovable page)
Date: Fri, 6 Apr 2018 03:07:11 +0000
Message-ID: <20180406030706.GA2434@hori1.linux.bs1.fc.nec.co.jp>
References: <20180403082405.GA23809@hori1.linux.bs1.fc.nec.co.jp>
 <20180403083451.GG5501@dhcp22.suse.cz>
 <20180403105411.hknofkbn6rzs26oz@node.shutemov.name>
 <20180405085927.GC6312@dhcp22.suse.cz>
 <20180405122838.6a6b35psizem4tcy@node.shutemov.name>
 <20180405124830.GJ6312@dhcp22.suse.cz>
 <20180405134045.7axuun6d7ufobzj4@node.shutemov.name>
 <20180405150547.GN6312@dhcp22.suse.cz>
 <20180405155551.wchleyaf4rxooj6m@node.shutemov.name>
 <20180405160317.GP6312@dhcp22.suse.cz>
In-Reply-To: <20180405160317.GP6312@dhcp22.suse.cz>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <096B8D5FD15CDE4E9704754401AD7653@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Zi Yan <zi.yan@sent.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Hi everyone,

On Thu, Apr 05, 2018 at 06:03:17PM +0200, Michal Hocko wrote:
> On Thu 05-04-18 18:55:51, Kirill A. Shutemov wrote:
> > On Thu, Apr 05, 2018 at 05:05:47PM +0200, Michal Hocko wrote:
> > > On Thu 05-04-18 16:40:45, Kirill A. Shutemov wrote:
> > > > On Thu, Apr 05, 2018 at 02:48:30PM +0200, Michal Hocko wrote:
> > > [...]
> > > > > RIght, I confused the two. What is the proper layer to fix that t=
hen?
> > > > > rmap_walk_file?
> > > >=20
> > > > Maybe something like this? Totally untested.
> > >=20
> > > This looks way too complex. Why cannot we simply split THP page cache
> > > during migration?
> >=20
> > This way we unify the codepath for archictures that don't support THP
> > migration and shmem THP.
>=20
> But why? There shouldn't be really nothing to prevent THP (anon or
> shemem) to be migratable. If we cannot migrate it at once we can always
> split it. So why should we add another thp specific handling all over
> the place?

If thp migration works fine for shmem, we can keep anon/shmem thp to
be migratable and we don't need any ad-hoc workaround.
So I wrote a patch to enable it.
This patch does not change any shmem specific code, so I think that
it works for file thp (not only shmem,) but I don't test it yet.

Thanks,
Naoya Horiguchi
-----

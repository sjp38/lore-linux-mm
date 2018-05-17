Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1489F6B04F8
	for <linux-mm@kvack.org>; Thu, 17 May 2018 10:35:04 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id 6-v6so7378611itl.6
        for <linux-mm@kvack.org>; Thu, 17 May 2018 07:35:04 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id y131-v6si5035306itc.125.2018.05.17.07.35.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 May 2018 07:35:03 -0700 (PDT)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.4 \(3445.8.2\))
Subject: Re: [RFC] mm, THP: Map read-only text segments using large THP pages
From: William Kucharski <william.kucharski@oracle.com>
In-Reply-To: <20180517075740.GA31969@dhcp22.suse.cz>
Date: Thu, 17 May 2018 08:34:56 -0600
Content-Transfer-Encoding: quoted-printable
Message-Id: <59D5F452-4710-4CE9-9072-E587551D4862@oracle.com>
References: <5BB682E1-DD52-4AA9-83E9-DEF091E0C709@oracle.com>
 <20180517075740.GA31969@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-fsdevel@vger.kernel.org



> On May 17, 2018, at 1:57 AM, Michal Hocko <mhocko@kernel.org> wrote:
>=20
> [CCing Kirill and fs-devel]
>=20
> On Mon 14-05-18 07:12:13, William Kucharski wrote:
>> One of the downsides of THP as currently implemented is that it only =
supports
>> large page mappings for anonymous pages.
>=20
> There is a support for shmem merged already. ext4 was next on the plan
> AFAIR but I haven't seen any patches and Kirill was busy with other
> stuff IIRC.

I couldn't find anything that would specifically map text pages with =
large pages,
so perhaps this could be integrated with that or I may have simply =
missed changes
that would ultimately provide that functionality.

>=20
>> I embarked upon this prototype on the theory that it would be =
advantageous to=20
>> be able to map large ranges of read-only text pages using THP as =
well.
>=20
> Can the fs really support THP only for read mappings? What if those
> pages are to be shared in a writable mapping as well? In other words
> can this all work without a full THP support for a particular fs?

The integration with the page cache would indeed require filesystem =
support.

The end result I'd like to see is full R/W support for large THP pages; =
I
thought the RO text mapping proof of concept worthwhile to see what kind =
of
results we might see and what the thoughts of the community were.

Thanks for the feedback.

  -- Bill=

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id B74D08E00F6
	for <linux-mm@kvack.org>; Fri, 25 Jan 2019 21:58:18 -0500 (EST)
Received: by mail-yw1-f71.google.com with SMTP id x64so6094734ywc.6
        for <linux-mm@kvack.org>; Fri, 25 Jan 2019 18:58:18 -0800 (PST)
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id 62si15554948ybi.491.2019.01.25.18.58.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Jan 2019 18:58:17 -0800 (PST)
Subject: Re: [LSF/MM TOPIC] get_user_pages() pins in file mappings
References: <20190124090400.GE12184@quack2.suse.cz>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <041368e5-7bca-4093-47da-13f1608b0692@nvidia.com>
Date: Fri, 25 Jan 2019 18:58:15 -0800
MIME-Version: 1.0
In-Reply-To: <20190124090400.GE12184@quack2.suse.cz>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>, lsf-pc@lists.linux-foundation.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dan Williams <dan.j.williams@intel.com>, Jerome Glisse <jglisse@redhat.com>

On 1/24/19 1:04 AM, Jan Kara wrote:
> This is a joint proposal with Dan Williams, John Hubbard, and J=C3=A9r=C3=
=B4me
> Glisse.
>=20
> Last year we've talked with Dan about issues we have with filesystems and
> GUP [1]. The crux of the problem lies in the fact that there is no
> coordination (or even awareness) between filesystem working on a page (su=
ch
> as doing writeback) and GUP user modifying page contents and setting it
> dirty. This can (and we have user reports of this) lead to data corruptio=
n,
> kernel crashes, and other fun.
>=20
> Since last year we have worked together on solving these problems and we
> have explored couple dead ends as well as hopefully found solutions to so=
me
> of the partial problems. So I'd like to give some overview of where we
> stand and what remains to be solved and get thoughts from wider community
> about proposed solutions / problems to be solved.
>=20
> In particular we hope to have reasonably robust mechanism of identifying
> pages pinned by GUP (patches will be posted soon) - I'd like to run that =
by
> MM folks (unless discussion happens on mailing lists before LSF/MM). We
> also have ideas how filesystems should react to pinned page in their
> writepages methods - there will be some changes needed in some filesystem=
s
> to bounce the page if they need stable page contents. So I'd like to
> explain why we chose to do bouncing to fs people (i.e., why we cannot jus=
t
> wait, skip the page, do something else etc.) to save us from the same
> discussion with each fs separately and also hash out what the API for
> filesystems to do this should look like. Finally we plan to keep pinned
> page permanently dirty - again something I'd like to explain why we do th=
is
> and gather input from other people.
>=20
> This should be ideally shared MM + FS session.
>=20
> [1] https://lwn.net/Articles/753027/
>=20

Yes! I'd like to attend and discuss this, for sure.=20

Meanwhile, as usual, I'm a bit late on posting an updated RFC for the page
identification part, but that's coming very soon.


thanks,
--=20
John Hubbard
NVIDIA

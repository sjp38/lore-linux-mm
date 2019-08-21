Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7AA81C3A59E
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 17:28:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3885522D6D
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 17:28:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="aczAAOYj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3885522D6D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C407C6B0328; Wed, 21 Aug 2019 13:28:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BF0FE6B0329; Wed, 21 Aug 2019 13:28:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AE0166B032A; Wed, 21 Aug 2019 13:28:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0118.hostedemail.com [216.40.44.118])
	by kanga.kvack.org (Postfix) with ESMTP id 8BC0B6B0328
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 13:28:13 -0400 (EDT)
Received: from smtpin04.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 29BC640F0
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 17:28:13 +0000 (UTC)
X-FDA: 75847118466.04.owl24_47b0ced08090b
X-HE-Tag: owl24_47b0ced08090b
X-Filterd-Recvd-Size: 4109
Received: from mail-vs1-f46.google.com (mail-vs1-f46.google.com [209.85.217.46])
	by imf45.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 17:28:12 +0000 (UTC)
Received: by mail-vs1-f46.google.com with SMTP id m62so1858498vsc.8
        for <linux-mm@kvack.org>; Wed, 21 Aug 2019 10:28:12 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:from:date:message-id:subject:to;
        bh=Pxcwkel5NwWC/EnzdY8s8ZGNQTQ4ddIIJy9odqHj+ng=;
        b=aczAAOYj3EseHFh6Q04gpTCV7A1k6cB2ViZBvf2ywfgk/8BltmePw0QvCTQNRPBq8i
         FjWDebo1Y2//nCx+m4oLmneLfQaKpakVAgu81I7X9Wpbw9eXjDGtgz9Tc5p38jgLd6Uy
         Lg4ZOVqWEGL8IxNjBAUBxi9Py7nzMA8SmXr4a4Vc6k+4drO0a6NlYKqK28KrkmoMk0OF
         co28kB8QyyAq02chi15B/nFp82jauaEjGxlF7Xol1+I7j2uwGrer/ud3xWyBDxxUfY9k
         x+Y5KV5huY/SlDObDWMQIdIKSaVe1pbS+4lDO45nYXRXtJUh+AFoMKupx6GVjiK2td6m
         35NA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:from:date:message-id:subject:to;
        bh=Pxcwkel5NwWC/EnzdY8s8ZGNQTQ4ddIIJy9odqHj+ng=;
        b=KhDbdNEe7yoWYrYwi+SzT5nu81W7/qRAA9bFOucZ0ihkaZWBA1fgfEy3J3wHbZBYOC
         istJeXGgoPVNfjpkSmJ/AN6HryUI6hgsyFp0qgnuYOz0q9O1sZdeGl6t2DpLvJ183k8k
         suuSfPiLOdH2LU2DrUtIXR0kT4forwpFAnakEbt/ocAmiEcGJ/4sc3jr7aJOpLD/6def
         8EKrEL7ivsP+d6rd45BPBNdqDNlNbTrllz7Zvvf3kEb1b5e0L8j9ytuB5x3dz9IFFqhR
         dBdNUcAnZv4IvfOI2bvtnj1pLGimFoSsM8Mh9pnGXnjexE0wq268WdVVg01rpwnXKcZ/
         o5AQ==
X-Gm-Message-State: APjAAAWWNbcn6Ltgn6a8lskhWrfaGmSMVUVn4pEzb7tYZi4HWccaeH4n
	UME4O9MDoII47aKNhzbdsaa6lCujzaxz8jkldtjW5GjM
X-Google-Smtp-Source: APXvYqyMzkhPzyCZLWHxOofE+fk8Owoq9XFGZcMw+ob35QeKDQqZ9+C3u7/Qy9+/seM1s+2aPgzbqWOx4vxXoC2FKis=
X-Received: by 2002:a67:f450:: with SMTP id r16mr22270739vsn.119.1566408491894;
 Wed, 21 Aug 2019 10:28:11 -0700 (PDT)
MIME-Version: 1.0
From: Pankaj Suryawanshi <pankajssuryawanshi@gmail.com>
Date: Wed, 21 Aug 2019 22:58:03 +0530
Message-ID: <CACDBo56W1JGOc6w-NAf-hyWwJQ=vEDsAVAkO8MLLJBpQ0FTAcA@mail.gmail.com>
Subject: How cma allocation works ?
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
	Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, pankaj.suryawanshi@einfochips.com
Content-Type: multipart/alternative; boundary="000000000000bb8d2b0590a3e5a9"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.074812, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--000000000000bb8d2b0590a3e5a9
Content-Type: text/plain; charset="UTF-8"

Hello,

Hard time to understand cma allocation how differs from normal allocation ?

I know theoretically how cma works.

1. How it reserved the memory (start pfn to end pfn) ? what is bitmap_*
functions ?
2. How alloc_contig_range() works ? it isolate all the pages including
unevictable pages, what is the practical work flow ? all this works with
virtual pages or physical pages ?
3.what start_isolate_page_range() does ?
4. what alloc_contig_migrate_range does() ?
5.what isolate_migratepages_range(), reclaim_clean_pages_from_list(),
 migrate_pages() and shrink_page_list() is doing ?

Please let me know the flow with simple example.

Regards,
Pankaj

--000000000000bb8d2b0590a3e5a9
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Hello,<br><br>Hard time to understand cma allocation how d=
iffers from normal allocation ?<br><br>I know theoretically how cma works.<=
br>=C2=A0<br>1. How it reserved the memory (start pfn to end pfn) ? what is=
 bitmap_* functions ?<br>2. How alloc_contig_range() works ? it isolate all=
 the pages including unevictable pages, what is the practical work flow ? a=
ll this works with virtual pages or physical pages ?<br>3.what start_isolat=
e_page_range() does ?<br>4. what alloc_contig_migrate_range does() ?<br>5.w=
hat isolate_migratepages_range(), reclaim_clean_pages_from_list(), =C2=A0mi=
grate_pages() and shrink_page_list() is doing ?<br><br>Please let me know t=
he flow with simple example.<br><br>Regards,<br>Pankaj</div>

--000000000000bb8d2b0590a3e5a9--


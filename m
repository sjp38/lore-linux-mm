Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 580106B0185
	for <linux-mm@kvack.org>; Sun, 17 Oct 2010 00:05:24 -0400 (EDT)
Received: by iwn1 with SMTP id 1so3231364iwn.14
        for <linux-mm@kvack.org>; Sat, 16 Oct 2010 21:05:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20101013121829.c3320944.kamezawa.hiroyu@jp.fujitsu.com>
References: <20101013121527.8ec6a769.kamezawa.hiroyu@jp.fujitsu.com>
	<20101013121829.c3320944.kamezawa.hiroyu@jp.fujitsu.com>
Date: Sun, 17 Oct 2010 13:05:22 +0900
Message-ID: <AANLkTingNmxT6ww_VB_K=rjsgR+dHANLnyNkwV1Myvnk@mail.gmail.com>
Subject: Re: [RFC][PATCH 3/3] alloc contig pages with migration.
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Oct 13, 2010 at 12:18 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>
> Add an function to allocate contigous memory larger than MAX_ORDER.
> The main difference between usual page allocater is that this uses
> memory offline techiqueue (Isoalte pages and migrate remaining pages.).
>
> I think this is not 100% solution because we can't avoid fragmentation,
> but we have kernelcore=3D boot option and can create MOVABLE zone. That
> helps us to allow allocate a contigous range on demand.
>
> Maybe drivers can alloc contig pages by bootmem or hiding some memory
> from the kernel at boot. But if contig pages are necessary only in some
> situation, kernelcore=3D boot option and using page migration is a choice=

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id A47F19000C2
	for <linux-mm@kvack.org>; Sun,  3 Jul 2011 23:48:51 -0400 (EDT)
Received: by qyk32 with SMTP id 32so956821qyk.14
        for <linux-mm@kvack.org>; Sun, 03 Jul 2011 20:48:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CA367A4F.1479D%dmitry.fink@palm.com>
References: <CAEwNFnAYAWy4tabCuzGUwXjLpZVbxhKMmPXnhmCuH5pckOXBRw@mail.gmail.com>
	<CA367A4F.1479D%dmitry.fink@palm.com>
Date: Mon, 4 Jul 2011 12:48:48 +0900
Message-ID: <CAEwNFnD5=DEX1_iTZ4=7-1j4_r4hxMOsCb=NBT6EHYGFvH7fig@mail.gmail.com>
Subject: Re: [PATCH 1/1] mmap: Don't count shmem pages as free in __vm_enough_memory
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Dmitry Fink (Palm GBU)" <Dmitry.Fink@palm.com>
Cc: Dmitry Fink <finikk@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Mon, Jul 4, 2011 at 12:10 PM, Dmitry Fink (Palm GBU)
<Dmitry.Fink@palm.com> wrote:
> If I understand the logic correctly, even systems with swap set to
> OVERCOMMIT_GUESS are equally affected,
> what we are trying to do here is count the amount of immediately available
> and
> "potentially" available space both in memory and in swap. shmem is not
> immediately
> available, but it is not potentially available either, even if we swap it
> out, it will
> just be relocated from memory into swap, total amount of immediate and
> potentially
> available memory is not going to be affected, so we shouldn't count it as
> available
> in the first place.

Agree. I think this is good one rather than old description.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

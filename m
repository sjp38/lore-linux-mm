Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 018706B02AC
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 18:05:08 -0400 (EDT)
Received: from wpaz13.hot.corp.google.com (wpaz13.hot.corp.google.com [172.24.198.77])
	by smtp-out.google.com with ESMTP id o75M6LNK001063
	for <linux-mm@kvack.org>; Thu, 5 Aug 2010 15:06:21 -0700
Received: from pwj8 (pwj8.prod.google.com [10.241.219.72])
	by wpaz13.hot.corp.google.com with ESMTP id o75M6HaU010458
	for <linux-mm@kvack.org>; Thu, 5 Aug 2010 15:06:20 -0700
Received: by pwj8 with SMTP id 8so290656pwj.39
        for <linux-mm@kvack.org>; Thu, 05 Aug 2010 15:06:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100805132433.d1d7927b.akpm@linux-foundation.org>
References: <1280969004-29530-1-git-send-email-mrubin@google.com>
	<1280969004-29530-3-git-send-email-mrubin@google.com> <20100805132433.d1d7927b.akpm@linux-foundation.org>
From: Michael Rubin <mrubin@google.com>
Date: Thu, 5 Aug 2010 15:05:57 -0700
Message-ID: <AANLkTik9AMf1pmsguB843UC9Qq6KxBcWiN_qyeiDPp1O@mail.gmail.com>
Subject: Re: [PATCH 2/2] writeback: Adding pages_dirtied and
	pages_entered_writeback
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, jack@suse.cz, david@fromorbit.com, hch@lst.de, axboe@kernel.dk
List-ID: <linux-mm.kvack.org>

On Thu, Aug 5, 2010 at 1:24 PM, Andrew Morton <akpm@linux-foundation.org> w=
rote:
> On Wed, =A04 Aug 2010 17:43:24 -0700
> Michael Rubin <mrubin@google.com> wrote:
> Wait. =A0These counters appear in /proc/vmstat. =A0So why create standalo=
ne
> /proc/sys/vm files as well?

I did not know they would show up in /proc/vmstat.

I thought it made sense to put them in /proc/sys/vm since the other
writeback controls are there.
but have no problems just adding them to /prov/vmstat if that makes more se=
nse.

mrubin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

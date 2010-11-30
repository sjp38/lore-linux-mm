Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id C45066B004A
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 22:55:50 -0500 (EST)
Received: by qyk10 with SMTP id 10so5615811qyk.14
        for <linux-mm@kvack.org>; Mon, 29 Nov 2010 19:55:48 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101129103845.GA1195@localhost>
References: <20101129103845.GA1195@localhost>
Date: Tue, 30 Nov 2010 12:55:48 +0900
Message-ID: <AANLkTikQuhq0GMjiSUdctq_qSbJdZss_6pZkAZuF1Rck@mail.gmail.com>
Subject: Re: [BUGFIX] vmstat: fix dirty threshold ordering
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michael Rubin <mrubin@google.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, Nov 29, 2010 at 7:38 PM, Wu Fengguang <fengguang.wu@intel.com> wrot=
e:
> The nr_dirty_[background_]threshold fields are misplaced before the
> numa_* fields, and users will read strange values.
>
> This is the right order. Before patch, nr_dirty_background_threshold
> will read as 0 (the value from numa_miss).
>
> =A0 =A0 =A0 =A0numa_hit 128501
> =A0 =A0 =A0 =A0numa_miss 0
> =A0 =A0 =A0 =A0numa_foreign 0
> =A0 =A0 =A0 =A0numa_interleave 7388
> =A0 =A0 =A0 =A0numa_local 128501
> =A0 =A0 =A0 =A0numa_other 0
> =A0 =A0 =A0 =A0nr_dirty_threshold 144291
> =A0 =A0 =A0 =A0nr_dirty_background_threshold 72145
>
> Cc: Michael Rubin <mrubin@google.com>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

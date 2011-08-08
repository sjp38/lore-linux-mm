Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9F83C6B016F
	for <linux-mm@kvack.org>; Mon,  8 Aug 2011 10:27:16 -0400 (EDT)
Subject: Re: [PATCH 4/5] writeback: per task dirty rate limit
From: Peter Zijlstra <peterz@infradead.org>
Date: Mon, 08 Aug 2011 16:26:52 +0200
In-Reply-To: <20110808142318.GC22080@localhost>
References: <20110806084447.388624428@intel.com>
	 <20110806094527.002914580@intel.com> <1312811234.10488.34.camel@twins>
	 <20110808142318.GC22080@localhost>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Message-ID: <1312813612.10488.36.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, 2011-08-08 at 22:23 +0800, Wu Fengguang wrote:
> +       preempt_disable();
> +       p =3D &__get_cpu_var(dirty_leaks);

 p =3D &get_cpu_var(dirty_leaks);

> +       if (*p > 0 && current->nr_dirtied < ratelimit) {
> +               nr_pages_dirtied =3D min(*p, ratelimit - current->nr_dirt=
ied);
> +               *p -=3D nr_pages_dirtied;
> +               current->nr_dirtied +=3D nr_pages_dirtied;
> +       }
> +       preempt_enable();=20

put_cpu_var(dirty_leads);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

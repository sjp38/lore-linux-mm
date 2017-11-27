Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id C1E7C6B0038
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 14:18:01 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id l138so13080840oib.0
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 11:18:01 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t30sor7480034ote.329.2017.11.27.11.18.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 Nov 2017 11:18:00 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171127101232.ykriowhatecnvjvg@dhcp22.suse.cz>
References: <23066.59196.909026.689706@gargle.gargle.HOWL> <20171127101232.ykriowhatecnvjvg@dhcp22.suse.cz>
From: Mikael Pettersson <mikpelinux@gmail.com>
Date: Mon, 27 Nov 2017 20:18:00 +0100
Message-ID: <CAM43=SPVvBTPz31Uu=iz3fpS9tb75uSmL=pYP3AfsfmYr9u4Og@mail.gmail.com>
Subject: Re: [PATCH] mm: disable `vm.max_map_count' sysctl limit
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, Linux API <linux-api@vger.kernel.org>

On Mon, Nov 27, 2017 at 11:12 AM, Michal Hocko <mhocko@kernel.org> wrote:
> > I've kept the kernel tunable to not break the API towards user-space,
> > but it's a no-op now.  Also the distinction between split_vma() and
> > __split_vma() disappears, so they are merged.
>
> Could you be more explicit about _why_ we need to remove this tunable?
> I am not saying I disagree, the removal simplifies the code but I do not
> really see any justification here.

In principle you don't "need" to, as those that know about it can bump it
to some insanely high value and get on with life.  Meanwhile those that don't
(and I was one of them until fairly recently, and I'm no newcomer to Unix or
Linux) get to scratch their heads and wonder why the kernel says ENOMEM
when one has loads of free RAM.

But what _is_ the justification for having this arbitrary limit?
There might have
been historical reasons, but at least ELF core dumps are no longer a problem.

/Mikael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

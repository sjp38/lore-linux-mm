Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id D4BC5280319
	for <linux-mm@kvack.org>; Fri, 17 Jul 2015 05:28:03 -0400 (EDT)
Received: by pdjr16 with SMTP id r16so59740286pdj.3
        for <linux-mm@kvack.org>; Fri, 17 Jul 2015 02:28:03 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id kv6si17673749pbc.127.2015.07.17.02.28.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Jul 2015 02:28:02 -0700 (PDT)
Date: Fri, 17 Jul 2015 12:27:44 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH -mm v8 4/7] proc: add kpagecgroup file
Message-ID: <20150717092744.GF2001@esperanza>
References: <cover.1436967694.git.vdavydov@parallels.com>
 <c6cbd44b9d5127cdaaa6f7d330e9bf715ec55534.1436967694.git.vdavydov@parallels.com>
 <CAJu=L58kZW2WRpx8wLx=FXdS29BJ+euLRdDcTXJKwf-VLT6SCA@mail.gmail.com>
 <20150716092841.GA2001@esperanza>
 <CAJu=L5_AUFv=Bh2WiWwOsMx41z_X0cAum_WkNikSE4Bo0r+wfQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <CAJu=L5_AUFv=Bh2WiWwOsMx41z_X0cAum_WkNikSE4Bo0r+wfQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andres Lagar-Cavilla <andreslc@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jonathan Corbet <corbet@lwn.net>, linux-api@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Jul 16, 2015 at 12:04:59PM -0700, Andres Lagar-Cavilla wrote:
> On Thu, Jul 16, 2015 at 2:28 AM, Vladimir Davydov <vdavydov@parallels.com>
> wrote:
> 
> > On Wed, Jul 15, 2015 at 12:03:18PM -0700, Andres Lagar-Cavilla wrote:
> > > For both /proc/kpage* interfaces you add (and more critically for the
> > > rmap-causing one, kpageidle):
> > >
> > > It's a good idea to do cond_sched(). Whether after each pfn, each Nth
> > > pfn, each put_user, I leave to you, but a reasonable cadence is
> > > needed, because user-space can call this on the entire physical
> > > address space, and that's a lot of work to do without re-scheduling.
> >
> > I really don't think it's necessary. These files can only be
> > read/written by the root, who has plenty ways to kill the system anyway.
> > The program that is allowed to read/write these files must be conscious
> > and do it in batches of reasonable size. AFAICS the same reasoning
> > already lays behind /proc/kpagecount and /proc/kpageflag, which also do
> > not thrust the "right" batch size on their readers.
> >
> 
> Beg to disagree. You're conflating intended use with system health. A
> cond_sched() is a one-liner.

I would still prefer not to clutter the code with cond_resched's, but I
don't think it's a matter worth arguing upon, so I'll prepare a patch
that makes all /proc/kapge* files issue cond_resched periodically and
leave it up to Andrew to decide if it should be applied or not.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

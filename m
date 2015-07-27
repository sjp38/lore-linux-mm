Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 271A36B0253
	for <linux-mm@kvack.org>; Mon, 27 Jul 2015 15:25:30 -0400 (EDT)
Received: by pachj5 with SMTP id hj5so55977619pac.3
        for <linux-mm@kvack.org>; Mon, 27 Jul 2015 12:25:29 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id d6si46306561pas.51.2015.07.27.12.25.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Jul 2015 12:25:29 -0700 (PDT)
Date: Mon, 27 Jul 2015 12:25:27 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -mm v9 0/8] idle memory tracking
Message-Id: <20150727122527.c6f7786177e9b5096e623d18@linux-foundation.org>
In-Reply-To: <CAGXu5jLPT-2c_H3kjCzbVgRKQO0xMskVd7JcAMmWZSmFgzZ4ng@mail.gmail.com>
References: <cover.1437303956.git.vdavydov@parallels.com>
	<20150721163402.43ad2527d9b8caa476a1c9e1@linux-foundation.org>
	<CAGXu5jLPT-2c_H3kjCzbVgRKQO0xMskVd7JcAMmWZSmFgzZ4ng@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Vladimir Davydov <vdavydov@parallels.com>, Andres Lagar-Cavilla <andreslc@google.com>, Minchan Kim <minchan@kernel.org>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jonathan Corbet <corbet@lwn.net>, Linux API <linux-api@vger.kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Cgroups <cgroups@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, 27 Jul 2015 12:18:57 -0700 Kees Cook <keescook@chromium.org> wrote:

> > Why were these put in /proc anyway?  Rather than under /sys/fs/cgroup
> > somewhere?  Presumably because /proc/kpageidle is useful in non-memcg
> > setups.
> 
> Do we need a /proc/vm/ for holding these kinds of things? We're
> collecting a lot there. Or invent some way for this to be sensible in
> /sys?

/proc is the traditional place for such things (/proc/kpagecount,
/proc/kpageflags, /proc/pagetypeinfo).  But that was probably a
mistake.

/proc/sys/vm is rather a dumping ground of random tunables and
statuses, but yes, I do think that moving the kpageidle stuff into there
would be better.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

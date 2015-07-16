Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 78FE12802DE
	for <linux-mm@kvack.org>; Thu, 16 Jul 2015 05:28:57 -0400 (EDT)
Received: by pdbqm3 with SMTP id qm3so41400685pdb.0
        for <linux-mm@kvack.org>; Thu, 16 Jul 2015 02:28:57 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id xh6si12078158pbc.57.2015.07.16.02.28.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Jul 2015 02:28:56 -0700 (PDT)
Date: Thu, 16 Jul 2015 12:28:41 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH -mm v8 4/7] proc: add kpagecgroup file
Message-ID: <20150716092841.GA2001@esperanza>
References: <cover.1436967694.git.vdavydov@parallels.com>
 <c6cbd44b9d5127cdaaa6f7d330e9bf715ec55534.1436967694.git.vdavydov@parallels.com>
 <CAJu=L58kZW2WRpx8wLx=FXdS29BJ+euLRdDcTXJKwf-VLT6SCA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <CAJu=L58kZW2WRpx8wLx=FXdS29BJ+euLRdDcTXJKwf-VLT6SCA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andres Lagar-Cavilla <andreslc@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jonathan Corbet <corbet@lwn.net>, linux-api@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Jul 15, 2015 at 12:03:18PM -0700, Andres Lagar-Cavilla wrote:
> For both /proc/kpage* interfaces you add (and more critically for the
> rmap-causing one, kpageidle):
> 
> It's a good idea to do cond_sched(). Whether after each pfn, each Nth
> pfn, each put_user, I leave to you, but a reasonable cadence is
> needed, because user-space can call this on the entire physical
> address space, and that's a lot of work to do without re-scheduling.

I really don't think it's necessary. These files can only be
read/written by the root, who has plenty ways to kill the system anyway.
The program that is allowed to read/write these files must be conscious
and do it in batches of reasonable size. AFAICS the same reasoning
already lays behind /proc/kpagecount and /proc/kpageflag, which also do
not thrust the "right" batch size on their readers.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

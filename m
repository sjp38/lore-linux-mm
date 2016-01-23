Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f47.google.com (mail-lf0-f47.google.com [209.85.215.47])
	by kanga.kvack.org (Postfix) with ESMTP id 0BF656B0005
	for <linux-mm@kvack.org>; Sat, 23 Jan 2016 02:55:54 -0500 (EST)
Received: by mail-lf0-f47.google.com with SMTP id m198so59697047lfm.0
        for <linux-mm@kvack.org>; Fri, 22 Jan 2016 23:55:53 -0800 (PST)
Received: from mail-lb0-x244.google.com (mail-lb0-x244.google.com. [2a00:1450:4010:c04::244])
        by mx.google.com with ESMTPS id vz8si4540062lbb.124.2016.01.22.23.55.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Jan 2016 23:55:52 -0800 (PST)
Received: by mail-lb0-x244.google.com with SMTP id ad5so4076862lbc.3
        for <linux-mm@kvack.org>; Fri, 22 Jan 2016 23:55:52 -0800 (PST)
Date: Sat, 23 Jan 2016 10:55:51 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH 2/2] mm: limit VmData with RLIMIT_DATA
Message-ID: <20160123075550.GI2262@uranus>
References: <145353478067.23962.14991739413777907906.stgit@zurg>
 <145353478691.23962.7610086254586675400.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <145353478691.23962.7610086254586675400.stgit@zurg>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linuxfoundation.org>, linux-kernel@vger.kernel.org, Vegard Nossum <vegard.nossum@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Vladimir Davydov <vdavydov@virtuozzo.com>, Andy Lutomirski <luto@amacapital.net>, Quentin Casasnovas <quentin.casasnovas@oracle.com>, Kees Cook <keescook@google.com>, Willy Tarreau <w@1wt.eu>, Pavel Emelyanov <xemul@virtuozzo.com>

On Sat, Jan 23, 2016 at 10:39:47AM +0300, Konstantin Khlebnikov wrote:
> This adds is correct version of RLIMIT_DATA check.
> And kernel boot option "ignore_rlimit_data" for reverting old behavior.
> Also could be set by /sys/module/kernel/parameters/ignore_rlimit_data.
> 
> Signed-off-by: Konstantin Khlebnikov <koct9i@gmail.com>
Acked-by: Cyrill Gorcunov <gorcunov@openvz.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

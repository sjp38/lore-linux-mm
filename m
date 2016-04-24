Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f200.google.com (mail-lb0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 830CD6B0005
	for <linux-mm@kvack.org>; Sun, 24 Apr 2016 09:23:02 -0400 (EDT)
Received: by mail-lb0-f200.google.com with SMTP id os9so66338400lbb.1
        for <linux-mm@kvack.org>; Sun, 24 Apr 2016 06:23:02 -0700 (PDT)
Received: from mail-lf0-x235.google.com (mail-lf0-x235.google.com. [2a00:1450:4010:c07::235])
        by mx.google.com with ESMTPS id l17si9767859lbv.10.2016.04.24.06.23.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 24 Apr 2016 06:23:00 -0700 (PDT)
Received: by mail-lf0-x235.google.com with SMTP id j11so102506590lfb.1
        for <linux-mm@kvack.org>; Sun, 24 Apr 2016 06:23:00 -0700 (PDT)
Date: Sun, 24 Apr 2016 16:22:57 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH] mm: enable RLIMIT_DATA by default with workaround for
 valgrind
Message-ID: <20160424132257.GL2063@uranus.lan>
References: <146148524340.530.2185181436065386014.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <146148524340.530.2185181436065386014.stgit@zurg>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Christian Borntraeger <borntraeger@de.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>

On Sun, Apr 24, 2016 at 11:07:23AM +0300, Konstantin Khlebnikov wrote:
> Since commit 84638335900f ("mm: rework virtual memory accounting")
> RLIMIT_DATA limits both brk() and private mmap() but this's disabled by
> default because of incompatibility with older versions of valgrind.
...
Reviewed-by: Cyrill Gorcunov <gorcunov@openvz.org>

Thank you!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

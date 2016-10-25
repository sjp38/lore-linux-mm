Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 812346B0269
	for <linux-mm@kvack.org>; Tue, 25 Oct 2016 10:16:15 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id l201so5057521wmg.13
        for <linux-mm@kvack.org>; Tue, 25 Oct 2016 07:16:15 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id u21si3921974wmu.72.2016.10.25.07.16.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Oct 2016 07:16:14 -0700 (PDT)
Date: Tue, 25 Oct 2016 10:16:04 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH stable 4.4 0/4] mm: workingset backports
Message-ID: <20161025141604.GB13019@cmpxchg.org>
References: <20161025075148.31661-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161025075148.31661-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Stable tree <stable@vger.kernel.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Antonio SJ Musumeci <trapexit@spawn.link>, Jan Kara <jack@suse.cz>, Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Miklos Szeredi <miklos@szeredi.hu>

All 4 backport patches:

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

Thank you Michal.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

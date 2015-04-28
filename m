Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id C9C936B0032
	for <linux-mm@kvack.org>; Tue, 28 Apr 2015 19:10:03 -0400 (EDT)
Received: by pdbqd1 with SMTP id qd1so9623495pdb.2
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 16:10:03 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id cu9si36671007pad.177.2015.04.28.16.10.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Apr 2015 16:10:03 -0700 (PDT)
Date: Tue, 28 Apr 2015 16:10:01 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC 1/3] mm: mmap make MAP_LOCKED really mlock semantic
Message-Id: <20150428161001.e854fb3eaf82f738865130af@linux-foundation.org>
In-Reply-To: <1430223111-14817-2-git-send-email-mhocko@suse.cz>
References: <20150114095019.GC4706@dhcp22.suse.cz>
	<1430223111-14817-1-git-send-email-mhocko@suse.cz>
	<1430223111-14817-2-git-send-email-mhocko@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, Cyril Hrubis <chrubis@suse.cz>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Michael Kerrisk <mtk.manpages@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Tue, 28 Apr 2015 14:11:49 +0200 Michal Hocko <mhocko@suse.cz> wrote:

> The man page however says
> "
> MAP_LOCKED (since Linux 2.5.37)
>       Lock the pages of the mapped region into memory in the manner of
>       mlock(2).  This flag is ignored in older kernels.
> "

I'm trying to remember why we implemented MAP_LOCKED in the first
place.  Was it better than mmap+mlock in some fashion?

afaict we had a #define MAP_LOCKED in the header file but it wasn't
implemented, so we went and wired it up.  13 years ago:
https://lkml.org/lkml/2002/9/18/108


Anyway...  the third way of doing this is to use plain old mmap() while
mlockall(MCL_FUTURE) is in force.  Has anyone looked at that, checked
that the behaviour is sane and compared it with the mmap+mlock
behaviour, the MAP_LOCKED behaviour and the manpages?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

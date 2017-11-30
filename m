Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2F6F36B0038
	for <linux-mm@kvack.org>; Thu, 30 Nov 2017 01:58:41 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id u16so4293761pfh.7
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 22:58:41 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l18si2740140pfi.159.2017.11.29.22.58.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 29 Nov 2017 22:58:40 -0800 (PST)
Date: Thu, 30 Nov 2017 07:58:35 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/2] mm: introduce MAP_FIXED_SAFE
Message-ID: <20171130065835.dbw4ajh5q5whikhf@dhcp22.suse.cz>
References: <20171129144219.22867-1-mhocko@kernel.org>
 <CAGXu5jLa=b2HhjWXXTQunaZuz11qUhm5aNXHpS26jVqb=G-gfw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGXu5jLa=b2HhjWXXTQunaZuz11qUhm5aNXHpS26jVqb=G-gfw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Linux API <linux-api@vger.kernel.org>, Khalid Aziz <khalid.aziz@oracle.com>, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, Andrea Arcangeli <aarcange@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Florian Weimer <fweimer@redhat.com>, John Hubbard <jhubbard@nvidia.com>, Abdul Haleem <abdhalee@linux.vnet.ibm.com>, Joel Stanley <joel@jms.id.au>

On Wed 29-11-17 14:25:36, Kees Cook wrote:
> On Wed, Nov 29, 2017 at 6:42 AM, Michal Hocko <mhocko@kernel.org> wrote:
> > The first patch introduced MAP_FIXED_SAFE which enforces the given
> > address but unlike MAP_FIXED it fails with ENOMEM if the given range
> > conflicts with an existing one. The flag is introduced as a completely
> 
> I still think this name should be better. "SAFE" doesn't say what it's
> safe from...

It is safe in a sense it doesn't perform any address space dangerous
operations. mmap is _inherently_ about the address space so the context
should be kind of clear.

> MAP_FIXED_UNIQUE
> MAP_FIXED_ONCE
> MAP_FIXED_FRESH

Well, I can open a poll for the best name, but none of those you are
proposing sound much better to me. Yeah, naming sucks...
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 608106B039F
	for <linux-mm@kvack.org>; Tue,  4 Apr 2017 11:59:02 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id t189so2553280wmt.9
        for <linux-mm@kvack.org>; Tue, 04 Apr 2017 08:59:02 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j1si4629773wrc.285.2017.04.04.08.59.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 04 Apr 2017 08:59:01 -0700 (PDT)
Date: Tue, 4 Apr 2017 17:58:56 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: Add additional consistency check
Message-ID: <20170404155856.GP15132@dhcp22.suse.cz>
References: <20170331164028.GA118828@beast>
 <20170404113022.GC15490@dhcp22.suse.cz>
 <alpine.DEB.2.20.1704041005570.23420@east.gentwo.org>
 <20170404151600.GN15132@dhcp22.suse.cz>
 <CAGXu5jJ0CzoELUacbsQc9Uf4fDnQDoeTFmhULtG+8Ddt4XMarA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGXu5jJ0CzoELUacbsQc9Uf4fDnQDoeTFmhULtG+8Ddt4XMarA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue 04-04-17 08:46:02, Kees Cook wrote:
> On Tue, Apr 4, 2017 at 8:16 AM, Michal Hocko <mhocko@kernel.org> wrote:
> > On Tue 04-04-17 10:07:23, Cristopher Lameter wrote:
> >> On Tue, 4 Apr 2017, Michal Hocko wrote:
> >>
> >> > NAK without a proper changelog. Seriously, we do not blindly apply
> >> > changes from other projects without a deep understanding of all
> >> > consequences.
> >>
> >> Functionalitywise this is trivial. A page must be a slab page in order to
> >> be able to determine the slab cache of an object. Its definitely not ok if
> >> the page is not a slab page.
> >
> > Yes, but we do not have to blow the kernel, right? Why cannot we simply
> > leak that memory?
> 
> I can put this behind CHECK_DATA_CORRUPTION() instead of BUG(), which
> allows the system builder to choose between WARN and BUG. Some people
> absolutely want the kernel to BUG on data corruption as it could be an
> attack.

CHECK_DATA_CORRUPTION sounds as better fit to me. This would, however
require to handle the potenial corruption by returning and leaking the
memory.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

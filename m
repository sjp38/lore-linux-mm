Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7D86A6B0038
	for <linux-mm@kvack.org>; Tue,  4 Apr 2017 11:16:05 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id w11so28933602wrc.2
        for <linux-mm@kvack.org>; Tue, 04 Apr 2017 08:16:05 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y129si20183465wmd.48.2017.04.04.08.16.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 04 Apr 2017 08:16:04 -0700 (PDT)
Date: Tue, 4 Apr 2017 17:16:00 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: Add additional consistency check
Message-ID: <20170404151600.GN15132@dhcp22.suse.cz>
References: <20170331164028.GA118828@beast>
 <20170404113022.GC15490@dhcp22.suse.cz>
 <alpine.DEB.2.20.1704041005570.23420@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1704041005570.23420@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 04-04-17 10:07:23, Cristopher Lameter wrote:
> On Tue, 4 Apr 2017, Michal Hocko wrote:
> 
> > NAK without a proper changelog. Seriously, we do not blindly apply
> > changes from other projects without a deep understanding of all
> > consequences.
> 
> Functionalitywise this is trivial. A page must be a slab page in order to
> be able to determine the slab cache of an object. Its definitely not ok if
> the page is not a slab page.

Yes, but we do not have to blow the kernel, right? Why cannot we simply
leak that memory?

> The main issue that may exist here is the adding of overhead to a critical
> code path like kfree().

Yes, nothing is for free. But if the attack space is real then we
probably want to sacrifice few cycles (to simply return ASAP without
further further processing). This all should be in the changelog ideally
with some numbers. I suspect this would be hard to measure in most
workloads.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

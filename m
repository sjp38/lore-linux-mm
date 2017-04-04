Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id B89776B0038
	for <linux-mm@kvack.org>; Tue,  4 Apr 2017 15:58:09 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id t68so70830488iof.16
        for <linux-mm@kvack.org>; Tue, 04 Apr 2017 12:58:09 -0700 (PDT)
Received: from resqmta-ch2-02v.sys.comcast.net (resqmta-ch2-02v.sys.comcast.net. [2001:558:fe21:29:69:252:207:34])
        by mx.google.com with ESMTPS id g98si19180577iod.141.2017.04.04.12.58.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Apr 2017 12:58:09 -0700 (PDT)
Date: Tue, 4 Apr 2017 14:58:06 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm: Add additional consistency check
In-Reply-To: <20170404194220.GT15132@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.20.1704041457030.28085@east.gentwo.org>
References: <20170331164028.GA118828@beast> <20170404113022.GC15490@dhcp22.suse.cz> <alpine.DEB.2.20.1704041005570.23420@east.gentwo.org> <20170404151600.GN15132@dhcp22.suse.cz> <alpine.DEB.2.20.1704041412050.27424@east.gentwo.org>
 <20170404194220.GT15132@dhcp22.suse.cz>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 4 Apr 2017, Michal Hocko wrote:

> On Tue 04-04-17 14:13:06, Cristopher Lameter wrote:
> > On Tue, 4 Apr 2017, Michal Hocko wrote:
> >
> > > Yes, but we do not have to blow the kernel, right? Why cannot we simply
> > > leak that memory?
> >
> > Because it is a serious bug to attempt to free a non slab object using
> > slab operations. This is often the result of memory corruption, coding
> > errs etc. The system needs to stop right there.
>
> Why when an alternative is a memory leak?

Because the slab allocators fail also in case you free an object multiple
times etc etc. Continuation is supported by enabling a special resiliency
feature via the kernel command line. The alternative is selectable but not
the default.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

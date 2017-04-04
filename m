Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id DF54A6B0397
	for <linux-mm@kvack.org>; Tue,  4 Apr 2017 15:42:25 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id x89so2776408wma.0
        for <linux-mm@kvack.org>; Tue, 04 Apr 2017 12:42:25 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 32si25878696wrc.11.2017.04.04.12.42.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 04 Apr 2017 12:42:24 -0700 (PDT)
Date: Tue, 4 Apr 2017 21:42:21 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: Add additional consistency check
Message-ID: <20170404194220.GT15132@dhcp22.suse.cz>
References: <20170331164028.GA118828@beast>
 <20170404113022.GC15490@dhcp22.suse.cz>
 <alpine.DEB.2.20.1704041005570.23420@east.gentwo.org>
 <20170404151600.GN15132@dhcp22.suse.cz>
 <alpine.DEB.2.20.1704041412050.27424@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1704041412050.27424@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 04-04-17 14:13:06, Cristopher Lameter wrote:
> On Tue, 4 Apr 2017, Michal Hocko wrote:
> 
> > Yes, but we do not have to blow the kernel, right? Why cannot we simply
> > leak that memory?
> 
> Because it is a serious bug to attempt to free a non slab object using
> slab operations. This is often the result of memory corruption, coding
> errs etc. The system needs to stop right there.

Why when an alternative is a memory leak?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

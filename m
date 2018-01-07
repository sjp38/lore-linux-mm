Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id E1BB16B0272
	for <linux-mm@kvack.org>; Sun,  7 Jan 2018 05:18:54 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id t65so5482605pfe.22
        for <linux-mm@kvack.org>; Sun, 07 Jan 2018 02:18:54 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h192si6824904pfe.371.2018.01.07.02.18.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 07 Jan 2018 02:18:53 -0800 (PST)
Date: Sun, 7 Jan 2018 11:18:47 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 4.14 023/159] mm/sparsemem: Allocate mem_section at
 runtime for CONFIG_SPARSEMEM_EXTREME=y
Message-ID: <20180107101847.GC24862@dhcp22.suse.cz>
References: <20171222084623.668990192@linuxfoundation.org>
 <20171222084625.007160464@linuxfoundation.org>
 <1515302062.6507.18.camel@gmx.de>
 <20180107091115.GB29329@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180107091115.GB29329@kroah.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Mike Galbraith <efault@gmx.de>, linux-kernel@vger.kernel.org, stable@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Borislav Petkov <bp@suse.de>, Cyrill Gorcunov <gorcunov@openvz.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>

On Sun 07-01-18 10:11:15, Greg KH wrote:
> On Sun, Jan 07, 2018 at 06:14:22AM +0100, Mike Galbraith wrote:
> > On Fri, 2017-12-22 at 09:45 +0100, Greg Kroah-Hartman wrote:
> > > 4.14-stable review patch.  If anyone has any objections, please let me know.
> > 
> > FYI, this broke kdump, or rather the makedumpfile part thereof.
> >  Forward looking wreckage is par for the kdump course, but...
> 
> Is it also broken in Linus's tree with this patch?  Or is there an
> add-on patch that I should apply to 4.14 to resolve this issue there?

This one http://lkml.kernel.org/r/1513932498-20350-1-git-send-email-bhe@redhat.com
I guess.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id B315A6B0270
	for <linux-mm@kvack.org>; Mon, 29 Feb 2016 10:03:31 -0500 (EST)
Received: by mail-wm0-f52.google.com with SMTP id p65so72572806wmp.1
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 07:03:31 -0800 (PST)
Received: from mail-wm0-x229.google.com (mail-wm0-x229.google.com. [2a00:1450:400c:c09::229])
        by mx.google.com with ESMTPS id hh4si32577222wjc.172.2016.02.29.07.03.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Feb 2016 07:03:29 -0800 (PST)
Received: by mail-wm0-x229.google.com with SMTP id l68so40821620wml.0
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 07:03:29 -0800 (PST)
Date: Mon, 29 Feb 2016 18:03:27 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 0/18] change mmap_sem taken for write killable
Message-ID: <20160229150327.GA13188@node.shutemov.name>
References: <1456752417-9626-1-git-send-email-mhocko@kernel.org>
 <20160229140416.GA12506@node.shutemov.name>
 <20160229141622.GC16930@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160229141622.GC16930@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Alex Deucher <alexander.deucher@amd.com>, Alex Thorlton <athorlton@sgi.com>, Andrea Arcangeli <aarcange@redhat.com>, Andy Lutomirski <luto@amacapital.net>, Benjamin LaHaise <bcrl@kvack.org>, Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>, Daniel Vetter <daniel.vetter@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, David Airlie <airlied@linux.ie>, Davidlohr Bueso <dave@stgolabs.net>, David Rientjes <rientjes@google.com>, "H . Peter Anvin" <hpa@zytor.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Konstantin Khlebnikov <koct9i@gmail.com>, linux-arch@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Petr Cermak <petrcermak@chromium.org>, Thomas Gleixner <tglx@linutronix.de>

On Mon, Feb 29, 2016 at 03:16:22PM +0100, Michal Hocko wrote:
> On Mon 29-02-16 17:04:16, Kirill A. Shutemov wrote:
> [...]
> > > Most of the patches are really trivial because the lock is help from a
> > > shallow syscall paths where we can return EINTR trivially. Others seem
> > > to be easy as well as the callers are already handling fatal errors and
> > > bail and return to userspace which should be sufficient to handle the
> > > failure gracefully. I am not familiar with all those code paths so a
> > > deeper review is really appreciated.
> > 
> > What about effect on userspace? IIUC, we would have now EINTR returned
> > from bunch of syscall, which haven't had this errno on the table before.
> > Should we care?
> 
> Those function will return EINTR only when the current was _killed_ when
> we do not return to the userspace. So there shouldn't be any visible
> effect.

Ah. I confused killable with interruptible.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

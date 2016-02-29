Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f179.google.com (mail-qk0-f179.google.com [209.85.220.179])
	by kanga.kvack.org (Postfix) with ESMTP id 316F6828E1
	for <linux-mm@kvack.org>; Mon, 29 Feb 2016 12:58:25 -0500 (EST)
Received: by mail-qk0-f179.google.com with SMTP id s5so59367566qkd.0
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 09:58:25 -0800 (PST)
Date: Mon, 29 Feb 2016 18:58:17 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 07/18] mm, proc: make clear_refs killable
Message-ID: <20160229175816.GE3615@redhat.com>
References: <1456752417-9626-1-git-send-email-mhocko@kernel.org>
 <1456752417-9626-8-git-send-email-mhocko@kernel.org>
 <20160229173845.GC3615@redhat.com>
 <20160229175338.GM16930@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160229175338.GM16930@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Alex Deucher <alexander.deucher@amd.com>, Alex Thorlton <athorlton@sgi.com>, Andrea Arcangeli <aarcange@redhat.com>, Andy Lutomirski <luto@amacapital.net>, Benjamin LaHaise <bcrl@kvack.org>, Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>, Daniel Vetter <daniel.vetter@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, David Airlie <airlied@linux.ie>, Davidlohr Bueso <dave@stgolabs.net>, David Rientjes <rientjes@google.com>, "H . Peter Anvin" <hpa@zytor.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Konstantin Khlebnikov <koct9i@gmail.com>, linux-arch@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <peterz@infradead.org>, Petr Cermak <petrcermak@chromium.org>, Thomas Gleixner <tglx@linutronix.de>

On 02/29, Michal Hocko wrote:
>
> On Mon 29-02-16 18:38:45, Oleg Nesterov wrote:
> 
> > In this case you do not need put_task_struct().
> 
> Why not? Both are after get_proc_task which takes a reference to the
> task...

Yes, but we already have put_task_struct(task) in the "out_mm" path, so
"goto out_mm" should work just fine?

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

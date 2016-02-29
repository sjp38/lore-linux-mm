Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id C3A3E6B0272
	for <linux-mm@kvack.org>; Mon, 29 Feb 2016 08:31:55 -0500 (EST)
Received: by mail-wm0-f42.google.com with SMTP id l68so36888829wml.0
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 05:31:55 -0800 (PST)
Date: Mon, 29 Feb 2016 14:31:53 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/18] change mmap_sem taken for write killable
Message-ID: <20160229133153.GA16930@dhcp22.suse.cz>
References: <1456752417-9626-1-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1456752417-9626-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Alex Deucher <alexander.deucher@amd.com>, Alex Thorlton <athorlton@sgi.com>, Andrea Arcangeli <aarcange@redhat.com>, Andy Lutomirski <luto@amacapital.net>, Benjamin LaHaise <bcrl@kvack.org>, Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>, Daniel Vetter <daniel.vetter@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, David Airlie <airlied@linux.ie>, Davidlohr Bueso <dave@stgolabs.net>, David Rientjes <rientjes@google.com>, "H . Peter Anvin" <hpa@zytor.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Konstantin Khlebnikov <koct9i@gmail.com>, linux-arch@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Petr Cermak <petrcermak@chromium.org>, Thomas Gleixner <tglx@linutronix.de>

On Mon 29-02-16 14:26:39, Michal Hocko wrote:
[...]
> As this work is touching more areas which are not directly connected I
> have tried to keep the CC list as small as possible and people who I
> believed would be familiar are CCed only to the specific patches (all
> should have received the cover though).

Damnt it. I thought that git-send-email will not use the same CC list
for all patches and use it only for the cover if the particular patches
have their CC list. I am sorry for the excessive spamming!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

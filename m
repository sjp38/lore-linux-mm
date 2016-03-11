Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id D182D6B0253
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 05:35:36 -0500 (EST)
Received: by mail-wm0-f52.google.com with SMTP id l68so11807582wml.1
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 02:35:36 -0800 (PST)
Subject: Re: [PATCH 05/18] mm, elf: handle vm_brk error
References: <1456752417-9626-1-git-send-email-mhocko@kernel.org>
 <1456752417-9626-6-git-send-email-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56E29F75.4010004@suse.cz>
Date: Fri, 11 Mar 2016 11:35:33 +0100
MIME-Version: 1.0
In-Reply-To: <1456752417-9626-6-git-send-email-mhocko@kernel.org>
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, LKML <linux-kernel@vger.kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Alex Deucher <alexander.deucher@amd.com>, Alex Thorlton <athorlton@sgi.com>, Andrea Arcangeli <aarcange@redhat.com>, Andy Lutomirski <luto@amacapital.net>, Benjamin LaHaise <bcrl@kvack.org>, =?UTF-8?Q?Christian_K=c3=b6nig?= <christian.koenig@amd.com>, Daniel Vetter <daniel.vetter@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, David Airlie <airlied@linux.ie>, Davidlohr Bueso <dave@stgolabs.net>, David Rientjes <rientjes@google.com>, "H . Peter Anvin" <hpa@zytor.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Konstantin Khlebnikov <koct9i@gmail.com>, linux-arch@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Petr Cermak <petrcermak@chromium.org>, Thomas Gleixner <tglx@linutronix.de>, Michal Hocko <mhocko@suse.com>, Alexander Viro <viro@zeniv.linux.org.uk>

On 02/29/2016 02:26 PM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
>
> load_elf_library doesn't handle vm_brk failure although nothing really
> indicates it cannot do that because the function is allowed to fail
> due to vm_mmap failures already. This might be not a problem now
> but later patch will make vm_brk killable (resp. mmap_sem for write
> waiting will become killable) and so the failure will be more probable.
>
> Cc: Alexander Viro <viro@zeniv.linux.org.uk>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

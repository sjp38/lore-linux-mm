Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 7EFC36B0005
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 04:59:35 -0500 (EST)
Received: by mail-wm0-f41.google.com with SMTP id p65so10949692wmp.1
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 01:59:35 -0800 (PST)
Subject: Re: [PATCH 02/18] mm: make vm_mmap killable
References: <1456752417-9626-1-git-send-email-mhocko@kernel.org>
 <1456752417-9626-3-git-send-email-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56E29702.5030100@suse.cz>
Date: Fri, 11 Mar 2016 10:59:30 +0100
MIME-Version: 1.0
In-Reply-To: <1456752417-9626-3-git-send-email-mhocko@kernel.org>
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, LKML <linux-kernel@vger.kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Alex Deucher <alexander.deucher@amd.com>, Alex Thorlton <athorlton@sgi.com>, Andrea Arcangeli <aarcange@redhat.com>, Andy Lutomirski <luto@amacapital.net>, Benjamin LaHaise <bcrl@kvack.org>, =?UTF-8?Q?Christian_K=c3=b6nig?= <christian.koenig@amd.com>, Daniel Vetter <daniel.vetter@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, David Airlie <airlied@linux.ie>, Davidlohr Bueso <dave@stgolabs.net>, David Rientjes <rientjes@google.com>, "H . Peter Anvin" <hpa@zytor.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Konstantin Khlebnikov <koct9i@gmail.com>, linux-arch@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Petr Cermak <petrcermak@chromium.org>, Thomas Gleixner <tglx@linutronix.de>, Michal Hocko <mhocko@suse.com>, Al Viro <viro@zeniv.linux.org.uk>

On 02/29/2016 02:26 PM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
>
> All the callers of vm_mmap seem to check for the failure already
> and bail out in one way or another on the error which means that

Hmm I'm not that sure about this one:
   17   1071  fs/binfmt_elf.c <<load_elf_binary>>

Assigns result of vm_mmap() to "error" variable which is never checked. 
Shouldn't __must_check trigger here?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

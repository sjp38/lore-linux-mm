Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id D93E86B0074
	for <linux-mm@kvack.org>; Tue,  4 Dec 2012 09:43:23 -0500 (EST)
Received: by mail-vb0-f50.google.com with SMTP id fr13so2940231vbb.9
        for <linux-mm@kvack.org>; Tue, 04 Dec 2012 06:43:23 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1354473824-19229-50-git-send-email-mingo@kernel.org>
References: <1354473824-19229-1-git-send-email-mingo@kernel.org>
	<1354473824-19229-50-git-send-email-mingo@kernel.org>
Date: Tue, 4 Dec 2012 06:43:22 -0800
Message-ID: <CANN689GwAuFcGsH54Ao=MBrAKJda+62XgkiUQ8MsBDgFYtEERw@mail.gmail.com>
Subject: Re: [PATCH 49/52] mm/rmap: Convert the struct anon_vma::mutex to an rwsem
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

On Sun, Dec 2, 2012 at 10:43 AM, Ingo Molnar <mingo@kernel.org> wrote:
> Convert the struct anon_vma::mutex to an rwsem, which will help
> in solving a page-migration scalability problem. (Addressed in
> a separate patch.)
>
> The conversion is simple and straightforward: in every case
> where we mutex_lock()ed we'll now down_write().

Looks good.

Reviewed-by: Michel Lespinasse <walken@google.com>

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f172.google.com (mail-ea0-f172.google.com [209.85.215.172])
	by kanga.kvack.org (Postfix) with ESMTP id 2986E6B00B7
	for <linux-mm@kvack.org>; Tue, 25 Feb 2014 18:03:59 -0500 (EST)
Received: by mail-ea0-f172.google.com with SMTP id l9so434110eaj.31
        for <linux-mm@kvack.org>; Tue, 25 Feb 2014 15:03:58 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id a43si46207285eei.58.2014.02.25.15.03.57
        for <linux-mm@kvack.org>;
        Tue, 25 Feb 2014 15:03:58 -0800 (PST)
Message-ID: <530D2141.50707@redhat.com>
Date: Tue, 25 Feb 2014 18:03:29 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] exec: kill the unnecessary mm->def_flags setting
 in load_elf_binary()
References: <cover.1392009759.rs.git.athorlton@sgi.com> <ad2c5e30c22c6398acb62641c054588f105cb4f4.1392009760.git.athorlton@sgi.com>
In-Reply-To: <ad2c5e30c22c6398acb62641c054588f105cb4f4.1392009760.git.athorlton@sgi.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Thorlton <athorlton@sgi.com>, linux-kernel@vger.kernel.org
Cc: Gerald Schaefer <gerald.schaefer@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Paolo Bonzini <pbonzini@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Oleg Nesterov <oleg@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Alexander Viro <viro@zeniv.linux.org.uk>, linux390@de.ibm.com, linux-s390@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org

On 02/25/2014 03:54 PM, Alex Thorlton wrote:
> load_elf_binary() sets current->mm->def_flags = def_flags and
> def_flags is always zero. Not only this looks strange, this is
> unnecessary because mm_init() has already set ->def_flags = 0. 
> 
> Signed-off-by: Alex Thorlton <athorlton@sgi.com>
> Suggested-by: Oleg Nesterov <oleg@redhat.com>

Acked-by: Rik van Riel <riel@redhat.com>


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

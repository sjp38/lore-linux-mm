Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id EE3586B00E4
	for <linux-mm@kvack.org>; Mon, 14 Apr 2014 11:49:05 -0400 (EDT)
Received: by mail-wg0-f41.google.com with SMTP id n12so8375891wgh.12
        for <linux-mm@kvack.org>; Mon, 14 Apr 2014 08:49:05 -0700 (PDT)
Received: from relay.sgi.com (relay2.sgi.com. [192.48.179.30])
        by mx.google.com with ESMTP id fy2si4848860wib.56.2014.04.14.08.49.04
        for <linux-mm@kvack.org>;
        Mon, 14 Apr 2014 08:49:04 -0700 (PDT)
Date: Mon, 14 Apr 2014 10:49:11 -0500
From: Alex Thorlton <athorlton@sgi.com>
Subject: Re: Documenting prctl() PR_SET_THP_DISABLE and PR_GET_THP_DISABLE
Message-ID: <20140414154911.GH3308@sgi.com>
References: <CAHO5Pa0VCzR7oqNXkwELuAsNQnnvF8Xoo=CuCaM64-GzjDuoFA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHO5Pa0VCzR7oqNXkwELuAsNQnnvF8Xoo=CuCaM64-GzjDuoFA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Kerrisk <mtk.manpages@gmail.com>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Paolo Bonzini <pbonzini@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Oleg Nesterov <oleg@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-mm <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>, linux-man@vger.kernel.org

On Mon, Apr 14, 2014 at 12:15:01PM +0200, Michael Kerrisk wrote:
> Alex,
> 
> Your commit a0715cc22601e8830ace98366c0c2bd8da52af52 added the prctl()
> PR_SET_THP_DISABLE and PR_GET_THP_DISABLE flags.
> 
> The text below attempts to document these flags for the prctl(3).
> Could you (and anyone else who is willing) please review the text
> below (one or two p[ieces of which are drawn from your commit message)
> to verify that it accurately reflects reality and your intent, and
> that I have not missed any significant details.

Looks fine to me!

- Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

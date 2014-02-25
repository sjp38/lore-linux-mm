Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f171.google.com (mail-qc0-f171.google.com [209.85.216.171])
	by kanga.kvack.org (Postfix) with ESMTP id 8342B6B00DB
	for <linux-mm@kvack.org>; Tue, 25 Feb 2014 16:10:51 -0500 (EST)
Received: by mail-qc0-f171.google.com with SMTP id x3so1311719qcv.30
        for <linux-mm@kvack.org>; Tue, 25 Feb 2014 13:10:51 -0800 (PST)
Received: from relay.sgi.com (relay3.sgi.com. [192.48.152.1])
        by mx.google.com with ESMTP id jx2si4588968qcb.19.2014.02.25.13.10.50
        for <linux-mm@kvack.org>;
        Tue, 25 Feb 2014 13:10:50 -0800 (PST)
Date: Tue, 25 Feb 2014 15:10:50 -0600
From: Alex Thorlton <athorlton@sgi.com>
Subject: Re: [PATCHv4 0/3] [RESEND] mm, thp: Add mm flag to control THP
Message-ID: <20140225211050.GL3041@sgi.com>
References: <cover.1392009759.rs.git.athorlton@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1392009759.rs.git.athorlton@sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Gerald Schaefer <gerald.schaefer@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Paolo Bonzini <pbonzini@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Oleg Nesterov <oleg@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Alexander Viro <viro@zeniv.linux.org.uk>, linux390@de.ibm.com, linux-s390@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org

On Tue, Feb 25, 2014 at 02:54:03PM -0600, Alex Thorlton wrote:
> (First send had too big of a cc list to make it into all the mailing lists.)

Sorry for the double-send to a couple of lists/people.  I got bumped
from linux-api for having too long of a cc list, and I figured it had
gotten bumped elsewhere as well.

- Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 9316E6B005D
	for <linux-mm@kvack.org>; Sun, 18 Nov 2012 14:33:19 -0500 (EST)
Received: by mail-we0-f169.google.com with SMTP id u3so1988533wey.14
        for <linux-mm@kvack.org>; Sun, 18 Nov 2012 11:33:17 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAGjg+kGKagtybwb+dTW8QVyhrjrQmfyPM9tv8asFQsP=z39suw@mail.gmail.com>
References: <1352826834-11774-1-git-send-email-mingo@kernel.org> <CAGjg+kGKagtybwb+dTW8QVyhrjrQmfyPM9tv8asFQsP=z39suw@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sun, 18 Nov 2012 09:32:57 -1000
Message-ID: <CA+55aFwc2q+oRohTxgwdydMPvivXjajX970qEmO_-GP4SFdPdw@mail.gmail.com>
Subject: Re: [PATCH 00/31] Latest numa/core patches, v15
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Shi <lkml.alex@gmail.com>
Cc: Ingo Molnar <mingo@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>

On Fri, Nov 16, 2012 at 10:45 PM, Alex Shi <lkml.alex@gmail.com> wrote:
> had caught a ops on my 2 sockets SNB EP server. but can not reproduce it.
> send out as a reminder:
> on tip/master, head : a7b7a8ad4476bb641c8455a4e0d7d0fd3eb86f90

This is an independent bug, nothing to do with the NUMA stuff. Fixed
in my tree now (commit 3587b1b097d70).

Of course, it's entirely possible that the NUMA patches are subtly
buggy and helped trigger the fanotify OVERFLOW event that had this
particular bug. But the oops itself is due to a real bug.

           Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

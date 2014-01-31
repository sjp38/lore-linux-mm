Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id 2F12B6B003C
	for <linux-mm@kvack.org>; Fri, 31 Jan 2014 13:25:50 -0500 (EST)
Received: by mail-ig0-f176.google.com with SMTP id j1so20370929iga.3
        for <linux-mm@kvack.org>; Fri, 31 Jan 2014 10:25:50 -0800 (PST)
Received: from relay.sgi.com (relay3.sgi.com. [192.48.152.1])
        by mx.google.com with ESMTP id mg9si15671469icc.37.2014.01.31.10.25.49
        for <linux-mm@kvack.org>;
        Fri, 31 Jan 2014 10:25:49 -0800 (PST)
Date: Fri, 31 Jan 2014 12:25:50 -0600
From: Alex Thorlton <athorlton@sgi.com>
Subject: Re: [PATCHv3 0/3] Add mm flag to control THP
Message-ID: <20140131182550.GB21948@sgi.com>
References: <1391192628-113858-1-git-send-email-athorlton@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1391192628-113858-1-git-send-email-athorlton@sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Christian Borntraeger <borntraeger@de.ibm.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Ingo Molnar <mingo@kernel.org>, Jiang Liu <liuj97@gmail.com>, Kees Cook <keescook@chromium.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Mel Gorman <mgorman@suse.de>, Oleg Nesterov <oleg@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Robin Holt <holt@sgi.com>, linux390@de.ibm.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-s390@vger.kernel.org

Ugh.  Screwed up the git send-email somehow.  Sorry for the duplicates
in the thread.  I'll get it right one of these days...

- Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

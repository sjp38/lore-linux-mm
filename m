Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7527B6B0284
	for <linux-mm@kvack.org>; Tue,  6 Feb 2018 12:27:57 -0500 (EST)
Received: by mail-lf0-f72.google.com with SMTP id c7so93320lfk.19
        for <linux-mm@kvack.org>; Tue, 06 Feb 2018 09:27:57 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l196sor2294687lfg.78.2018.02.06.09.27.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Feb 2018 09:27:55 -0800 (PST)
Date: Tue, 6 Feb 2018 20:27:53 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH] mm: Always print RLIMIT_DATA warning
Message-ID: <20180206172753.GD2002@uranus.lan>
References: <1517935505-9321-1-git-send-email-dwmw@amazon.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1517935505-9321-1-git-send-email-dwmw@amazon.co.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Woodhouse <dwmw@amazon.co.uk>
Cc: Konstantin Khlebnikov <koct9i@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Vegard Nossum <vegard.nossum@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Vladimir Davydov <vdavydov@virtuozzo.com>, Andy Lutomirski <luto@amacapital.net>, Quentin Casasnovas <quentin.casasnovas@oracle.com>, Kees Cook <keescook@google.com>, Willy Tarreau <w@1wt.eu>, Pavel Emelyanov <xemul@virtuozzo.com>, Laura Abbott <labbott@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Feb 06, 2018 at 04:45:05PM +0000, David Woodhouse wrote:
> The documentation for ignore_rlimit_data says that it will print a warning
> at first misuse. Yet it doesn't seem to do that. Fix the code to print
> the warning even when we allow the process to continue.
> 
> Signed-off-by: David Woodhouse <dwmw@amazon.co.uk>
> ---
> We should probably also do what Linus suggested in 
> https://lkml.org/lkml/2016/9/16/585
> 

Might be typo in docs I guess, Kostya?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

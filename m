Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 38B5D6B0493
	for <linux-mm@kvack.org>; Sat, 19 Nov 2016 02:17:13 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id o3so1021664wjo.1
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 23:17:13 -0800 (PST)
Received: from 1wt.eu (wtarreau.pck.nerim.net. [62.212.114.60])
        by mx.google.com with ESMTP id j199si5314546wmg.135.2016.11.18.23.17.11
        for <linux-mm@kvack.org>;
        Fri, 18 Nov 2016 23:17:12 -0800 (PST)
Date: Sat, 19 Nov 2016 08:17:00 +0100
From: Willy Tarreau <w@1wt.eu>
Subject: Re: [REVIEW][PATCH 0/3] Fixing ptrace vs exec vs userns interactions
Message-ID: <20161119071700.GA13347@1wt.eu>
References: <87k2d5nytz.fsf_-_@xmission.com>
 <CALCETrU4SZYUEPrv4JkpUpA+0sZ=EirZRftRDp+a5hce5E7HgA@mail.gmail.com>
 <87y41kjn6l.fsf@xmission.com>
 <20161019172917.GE1210@laptop.thejh.net>
 <CALCETrWSY1SRse5oqSwZ=goQ+ZALd2XcTP3SZ8ry49C8rNd98Q@mail.gmail.com>
 <87pomwi5p2.fsf@xmission.com>
 <CALCETrUz2oU6OYwQ9K4M-SUg6FeDsd6Q1gf1w-cJRGg2PdmK8g@mail.gmail.com>
 <87pomwghda.fsf@xmission.com>
 <CALCETrXA2EnE8X3HzetLG6zS8YSVjJQJrsSumTfvEcGq=r5vsw@mail.gmail.com>
 <87twb6avk8.fsf_-_@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87twb6avk8.fsf_-_@xmission.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Linux Containers <containers@lists.linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, Jann Horn <jann@thejh.net>, Kees Cook <keescook@chromium.org>, Andy Lutomirski <luto@amacapital.net>

Hi Eric,

On Thu, Nov 17, 2016 at 11:02:47AM -0600, Eric W. Biederman wrote:
> 
> With everyone heading to Kernel Summit and Plumbers I put this set of
> patches down temporarily.   Now is the time to take it back up and to
> make certain I am not missing something stupid in this set of patches.

I couldn't get your patch set to apply to any of the kernels I tried,
I manually adjusted some parts but the second one has too many rejects.
What kernel should I apply this to ? Or maybe some preliminary patches
are needed ?

Thanks,
Willy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

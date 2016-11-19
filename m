Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id C2DB96B04A2
	for <linux-mm@kvack.org>; Sat, 19 Nov 2016 13:38:00 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id y71so311088961pgd.0
        for <linux-mm@kvack.org>; Sat, 19 Nov 2016 10:38:00 -0800 (PST)
Received: from out02.mta.xmission.com (out02.mta.xmission.com. [166.70.13.232])
        by mx.google.com with ESMTPS id j13si14052401pgn.187.2016.11.19.10.37.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 19 Nov 2016 10:37:59 -0800 (PST)
From: ebiederm@xmission.com (Eric W. Biederman)
References: <87k2d5nytz.fsf_-_@xmission.com>
	<CALCETrU4SZYUEPrv4JkpUpA+0sZ=EirZRftRDp+a5hce5E7HgA@mail.gmail.com>
	<87y41kjn6l.fsf@xmission.com> <20161019172917.GE1210@laptop.thejh.net>
	<CALCETrWSY1SRse5oqSwZ=goQ+ZALd2XcTP3SZ8ry49C8rNd98Q@mail.gmail.com>
	<87pomwi5p2.fsf@xmission.com>
	<CALCETrUz2oU6OYwQ9K4M-SUg6FeDsd6Q1gf1w-cJRGg2PdmK8g@mail.gmail.com>
	<87pomwghda.fsf@xmission.com>
	<CALCETrXA2EnE8X3HzetLG6zS8YSVjJQJrsSumTfvEcGq=r5vsw@mail.gmail.com>
	<87twb6avk8.fsf_-_@xmission.com> <20161119071700.GA13347@1wt.eu>
Date: Sat, 19 Nov 2016 12:35:16 -0600
In-Reply-To: <20161119071700.GA13347@1wt.eu> (Willy Tarreau's message of "Sat,
	19 Nov 2016 08:17:00 +0100")
Message-ID: <87d1hrjp23.fsf@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain
Subject: Re: [REVIEW][PATCH 0/3] Fixing ptrace vs exec vs userns interactions
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Willy Tarreau <w@1wt.eu>
Cc: Linux Containers <containers@lists.linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, Jann Horn <jann@thejh.net>, Kees Cook <keescook@chromium.org>, Andy Lutomirski <luto@amacapital.net>

Willy Tarreau <w@1wt.eu> writes:

> Hi Eric,
>
> On Thu, Nov 17, 2016 at 11:02:47AM -0600, Eric W. Biederman wrote:
>> 
>> With everyone heading to Kernel Summit and Plumbers I put this set of
>> patches down temporarily.   Now is the time to take it back up and to
>> make certain I am not missing something stupid in this set of patches.
>
> I couldn't get your patch set to apply to any of the kernels I tried,
> I manually adjusted some parts but the second one has too many rejects.
> What kernel should I apply this to ? Or maybe some preliminary patches
> are needed ?

It is against my for-next branch, and there is one patch in there
that is significant.

The entire patchset should be at:
git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/user-namespace.git for-next

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

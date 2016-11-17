Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id B406F6B036C
	for <linux-mm@kvack.org>; Thu, 17 Nov 2016 18:17:29 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id a20so971884wme.5
        for <linux-mm@kvack.org>; Thu, 17 Nov 2016 15:17:29 -0800 (PST)
Received: from mail-wm0-x236.google.com (mail-wm0-x236.google.com. [2a00:1450:400c:c09::236])
        by mx.google.com with ESMTPS id mp16si4887292wjb.279.2016.11.17.15.17.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Nov 2016 15:17:28 -0800 (PST)
Received: by mail-wm0-x236.google.com with SMTP id g23so3144601wme.1
        for <linux-mm@kvack.org>; Thu, 17 Nov 2016 15:17:28 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <87shqpzpok.fsf_-_@xmission.com>
References: <20161019172917.GE1210@laptop.thejh.net> <CALCETrWSY1SRse5oqSwZ=goQ+ZALd2XcTP3SZ8ry49C8rNd98Q@mail.gmail.com>
 <87pomwi5p2.fsf@xmission.com> <CALCETrUz2oU6OYwQ9K4M-SUg6FeDsd6Q1gf1w-cJRGg2PdmK8g@mail.gmail.com>
 <87pomwghda.fsf@xmission.com> <CALCETrXA2EnE8X3HzetLG6zS8YSVjJQJrsSumTfvEcGq=r5vsw@mail.gmail.com>
 <87twb6avk8.fsf_-_@xmission.com> <87inrmavax.fsf_-_@xmission.com>
 <20161117204707.GB10421@1wt.eu> <CAGXu5jJc6TmzdVp+4OMDAt5Kd68hHbNBXaRPD8X0+m558hx3qw@mail.gmail.com>
 <20161117213258.GA10839@1wt.eu> <874m3522sy.fsf@xmission.com> <87shqpzpok.fsf_-_@xmission.com>
From: Kees Cook <keescook@chromium.org>
Date: Thu, 17 Nov 2016 15:17:27 -0800
Message-ID: <CAGXu5jKq9yKL16U2v8uzZt=kCa2U9JF8y4yUEpc5VgWXQghyWA@mail.gmail.com>
Subject: Re: [REVIEW][PATCH 2/3] ptrace: Don't allow accessing an undumpable mm
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Willy Tarreau <w@1wt.eu>, Linux Containers <containers@lists.linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, Jann Horn <jann@thejh.net>, Andy Lutomirski <luto@amacapital.net>

On Thu, Nov 17, 2016 at 2:50 PM, Eric W. Biederman
<ebiederm@xmission.com> wrote:
>
> It is the reasonable expectation that if an executable file is not
> readable there will be no way for a user without special privileges to
> read the file.  This is enforced in ptrace_attach but if ptrace
> is already attached before exec there is no enforcement for read-only
> executables.

Given the corner cases being fixed here, it might make sense to add
some simple tests to tools/testing/sefltests/ptrace/ to validate these
changes and avoid future regressions.

Regardless, it'll be nice to have this fixed. :)

-Kees

-- 
Kees Cook
Nexus Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 54F926B035D
	for <linux-mm@kvack.org>; Thu, 17 Nov 2016 16:33:09 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id a20so59732188wme.5
        for <linux-mm@kvack.org>; Thu, 17 Nov 2016 13:33:09 -0800 (PST)
Received: from 1wt.eu (wtarreau.pck.nerim.net. [62.212.114.60])
        by mx.google.com with ESMTP id 19si4465530wmt.10.2016.11.17.13.33.06
        for <linux-mm@kvack.org>;
        Thu, 17 Nov 2016 13:33:08 -0800 (PST)
Date: Thu, 17 Nov 2016 22:32:59 +0100
From: Willy Tarreau <w@1wt.eu>
Subject: Re: [REVIEW][PATCH 2/3] exec: Don't allow ptracing an exec of an
 unreadable file
Message-ID: <20161117213258.GA10839@1wt.eu>
References: <20161019172917.GE1210@laptop.thejh.net>
 <CALCETrWSY1SRse5oqSwZ=goQ+ZALd2XcTP3SZ8ry49C8rNd98Q@mail.gmail.com>
 <87pomwi5p2.fsf@xmission.com>
 <CALCETrUz2oU6OYwQ9K4M-SUg6FeDsd6Q1gf1w-cJRGg2PdmK8g@mail.gmail.com>
 <87pomwghda.fsf@xmission.com>
 <CALCETrXA2EnE8X3HzetLG6zS8YSVjJQJrsSumTfvEcGq=r5vsw@mail.gmail.com>
 <87twb6avk8.fsf_-_@xmission.com>
 <87inrmavax.fsf_-_@xmission.com>
 <20161117204707.GB10421@1wt.eu>
 <CAGXu5jJc6TmzdVp+4OMDAt5Kd68hHbNBXaRPD8X0+m558hx3qw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGXu5jJc6TmzdVp+4OMDAt5Kd68hHbNBXaRPD8X0+m558hx3qw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, Linux Containers <containers@lists.linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, Jann Horn <jann@thejh.net>, Andy Lutomirski <luto@amacapital.net>

On Thu, Nov 17, 2016 at 01:07:33PM -0800, Kees Cook wrote:
> I'm not opposed to a sysctl for this. Regardless, I think we need to
> embrace this idea now, though, since we'll soon end up with
> architectures that enforce executable-only memory, in which case
> ptrace will again fail. Almost better to get started here and then not
> have more surprises later.

Also that makes me realize that by far the largest use case of ptrace
is strace and that strace needs very little capabilities. I guess that
most users would be fine with having only pointers and not contents
for addresses or read/write of data, as they have on some other OSes,
when the process is not readable. But in my opinion when a process
is executable we should be able to trace its execution (even without
memory read access).

Willy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

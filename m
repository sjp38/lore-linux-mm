Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 72B5A6B0038
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 09:57:48 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id w13so51441546wmw.0
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 06:57:48 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o145si7497213wme.156.2016.11.30.06.57.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 30 Nov 2016 06:57:47 -0800 (PST)
Date: Wed, 30 Nov 2016 15:57:45 +0100 (CET)
From: Jiri Kosina <jikos@kernel.org>
Subject: Re: mm, floppy: unkillable task faulting on fd0
In-Reply-To: <CACT4Y+ZPL9pgvpanXVtYKW8LukzwLp6ajfPSuteQj2oGGkfCJQ@mail.gmail.com>
Message-ID: <alpine.LNX.2.00.1611301556130.29400@cbobk.fhfr.pm>
References: <CACT4Y+ZPL9pgvpanXVtYKW8LukzwLp6ajfPSuteQj2oGGkfCJQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, syzkaller <syzkaller@googlegroups.com>

On Fri, 18 Nov 2016, Dmitry Vyukov wrote:

> Hello,
> 
> The following program produces unkillable tasks blocked at the following stack:

I am pretty sure this got re-introduced by f2791e7eadf4, that basically 
reverts my attempt to work around you original report (that was fixed by 
09954bad44).

We'll have to figure out other way how to fix this that doesn't break 
odd userspace asumptions about semantics of O_NDELAY on floppies.

-- 
Jiri Kosina
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

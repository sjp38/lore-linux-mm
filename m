Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id DC59A6B00FD
	for <linux-mm@kvack.org>; Thu,  7 Nov 2013 15:29:54 -0500 (EST)
Received: by mail-pd0-f174.google.com with SMTP id z10so1102017pdj.5
        for <linux-mm@kvack.org>; Thu, 07 Nov 2013 12:29:54 -0800 (PST)
Received: from psmtp.com ([74.125.245.111])
        by mx.google.com with SMTP id pz2si4153608pac.144.2013.11.07.12.29.52
        for <linux-mm@kvack.org>;
        Thu, 07 Nov 2013 12:29:53 -0800 (PST)
Received: by mail-pb0-f73.google.com with SMTP id rp16so113031pbb.4
        for <linux-mm@kvack.org>; Thu, 07 Nov 2013 12:29:51 -0800 (PST)
From: Greg Thelen <gthelen@google.com>
Subject: Re: [PATCH v2 1/3] percpu: add test module for various percpu operations
References: <1382895017-19067-1-git-send-email-gthelen@google.com>
	<1382895017-19067-2-git-send-email-gthelen@google.com>
	<20131104160918.0c571b410cf165e9c4b4a502@linux-foundation.org>
Date: Thu, 07 Nov 2013 12:29:49 -0800
Message-ID: <xr93li10vttu.fsf@gthelen.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, handai.szj@taobao.com, x86@kernel.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org

On Mon, Nov 04 2013, Andrew Morton wrote:

> On Sun, 27 Oct 2013 10:30:15 -0700 Greg Thelen <gthelen@google.com> wrote:
>
>> Tests various percpu operations.
>
> Could you please take a look at the 32-bit build (this is i386):
>
> lib/percpu_test.c: In function 'percpu_test_init':
> lib/percpu_test.c:61: warning: integer constant is too large for 'long' type
> lib/percpu_test.c:61: warning: integer constant is too large for 'long' type
> lib/percpu_test.c:61: warning: integer constant is too large for 'long' type
> lib/percpu_test.c:61: warning: integer constant is too large for 'long' type
> lib/percpu_test.c:61: warning: integer constant is too large for 'long' type
> lib/percpu_test.c:61: warning: integer constant is too large for 'long' type
> lib/percpu_test.c:70: warning: integer constant is too large for 'long' type
> lib/percpu_test.c:70: warning: integer constant is too large for 'long' type
> lib/percpu_test.c:70: warning: integer constant is too large for 'long' type
> lib/percpu_test.c:70: warning: integer constant is too large for 'long' type
> lib/percpu_test.c:70: warning: integer constant is too large for 'long' type
> lib/percpu_test.c:70: warning: integer constant is too large for 'long' type
> lib/percpu_test.c:89: warning: integer constant is too large for 'long' type
> lib/percpu_test.c:89: warning: integer constant is too large for 'long' type
> lib/percpu_test.c:89: warning: integer constant is too large for 'long' type
> lib/percpu_test.c:89: warning: integer constant is too large for 'long' type
> lib/percpu_test.c:89: warning: integer constant is too large for 'long' type
> lib/percpu_test.c:89: warning: integer constant is too large for 'long' type
> lib/percpu_test.c:97: warning: integer constant is too large for 'long' type
> lib/percpu_test.c:97: warning: integer constant is too large for 'long' type
> lib/percpu_test.c:97: warning: integer constant is too large for 'long' type
> lib/percpu_test.c:97: warning: integer constant is too large for 'long' type
> lib/percpu_test.c:97: warning: integer constant is too large for 'long' type
> lib/percpu_test.c:97: warning: integer constant is too large for 'long' type
> lib/percpu_test.c:112: warning: integer constant is too large for 'long' type
> lib/percpu_test.c:112: warning: integer constant is too large for 'long' type
> lib/percpu_test.c:112: warning: integer constant is too large for 'long' type
> lib/percpu_test.c:112: warning: integer constant is too large for 'long' type
> lib/percpu_test.c:112: warning: integer constant is too large for 'long' type
> lib/percpu_test.c:112: warning: integer constant is too large for 'long' type

I was using gcc 4.6 which apparently adds LL suffix as needed.  Though
there were some other code problems with 32 bit beyond missing suffixes.
Fixed version below tested with both gcc 4.4 and gcc 4.6 on 32 and 64
bit x86.

---8<---

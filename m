Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id EE3066B0005
	for <linux-mm@kvack.org>; Fri,  4 May 2018 13:49:56 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id u127so16304182qka.9
        for <linux-mm@kvack.org>; Fri, 04 May 2018 10:49:56 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id e56-v6sor10858262qtc.151.2018.05.04.10.49.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 04 May 2018 10:49:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <22c34b1b-15d9-6a28-d7f2-697bac42bde2@oracle.com>
References: <20180426202619.2768-1-pasha.tatashin@oracle.com>
 <20180504082731.GA2782@outlook.office365.com> <CAGM2rebLfmWLybzNDPt-HTjZY2brkJ_8Bq37xVG_QDs=G+VuxQ@mail.gmail.com>
 <20180504160139.GA4693@outlook.office365.com> <22c34b1b-15d9-6a28-d7f2-697bac42bde2@oracle.com>
From: Andy Shevchenko <andy.shevchenko@gmail.com>
Date: Fri, 4 May 2018 20:49:54 +0300
Message-ID: <CAHp75Vf868eQuZUsmx=D62chUzBeYqdL0BxuOJ1qS17QdT-obw@mail.gmail.com>
Subject: Re: [v2] mm: access to uninitialized struct page
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: Andrei Vagin <avagin@virtuozzo.com>, Steven Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Michal Hocko <mhocko@suse.com>, Linux Memory Management List <linux-mm@kvack.org>, mgorman@techsingularity.net, Ingo Molnar <mingo@kernel.org>, "Peter Zijlstra (Intel)" <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Fengguang Wu <fengguang.wu@intel.com>, Dennis Zhou <dennisszhou@gmail.com>

On Fri, May 4, 2018 at 7:03 PM, Pavel Tatashin
<pasha.tatashin@oracle.com> wrote:
> Thank you, I will try to figure out what is happening.

+1 is here.

The last message I have seen on the console are:

[    4.690972] Non-volatile memory driver v1.3
[    4.703360] Linux agpgart interface v0.103
[    4.710282] loop: module loaded


Bisection points to this very patch.

I would suggest to revert ASAP and you may still continue
investigating on your side.

-- 
With Best Regards,
Andy Shevchenko

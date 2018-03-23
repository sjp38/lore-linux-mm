Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 927406B0030
	for <linux-mm@kvack.org>; Fri, 23 Mar 2018 15:27:14 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id t125so529039wmt.3
        for <linux-mm@kvack.org>; Fri, 23 Mar 2018 12:27:14 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a9sor1933275wri.8.2018.03.23.12.27.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 23 Mar 2018 12:27:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <f7897068-18a3-d88b-0458-5dcf05d7ffc2@intel.com>
References: <20180323180903.33B17168@viggo.jf.intel.com> <20180323180911.E43ACAB8@viggo.jf.intel.com>
 <CALvZod6F8x-smAE7sEGfJ3Ds5p6M5Qj6gd-P-VLejuBxfU6niQ@mail.gmail.com> <f7897068-18a3-d88b-0458-5dcf05d7ffc2@intel.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Fri, 23 Mar 2018 12:27:11 -0700
Message-ID: <CALvZod7sqAo0jHwD3xgwJExR6=hRDnf1bYUEX5BMjp3gJnrVGQ@mail.gmail.com>
Subject: Re: [PATCH 4/9] x86, pkeys: override pkey when moving away from PROT_EXEC
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linuxram@us.ibm.com, Thomas Gleixner <tglx@linutronix.de>, mpe@ellerman.id.au, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, shuah@kernel.org

On Fri, Mar 23, 2018 at 12:23 PM, Dave Hansen <dave.hansen@intel.com> wrote:
> On 03/23/2018 12:15 PM, Shakeel Butt wrote:
>>> We had a check for PROT_READ/WRITE, but it did not work
>>> for PROT_NONE.  This entirely removes the PROT_* checks,
>>> which ensures that PROT_NONE now works.
>>>
>>> Reported-by: Shakeel Butt <shakeelb@google.com>
>>> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
>> Should there be a 'Fixes' tag? Also should this patch go to stable?
>
> There could be, but I'm to lazy to dig up the original commit.  Does it
> matter?
>

I think for stable 'Fixes' is usually preferable.

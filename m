Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id C4C606B002E
	for <linux-mm@kvack.org>; Fri, 23 Mar 2018 15:30:02 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id y19so6369287pgv.18
        for <linux-mm@kvack.org>; Fri, 23 Mar 2018 12:30:02 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id x3-v6si9684413plo.479.2018.03.23.12.30.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Mar 2018 12:30:01 -0700 (PDT)
Subject: Re: [PATCH 4/9] x86, pkeys: override pkey when moving away from
 PROT_EXEC
References: <20180323180903.33B17168@viggo.jf.intel.com>
 <20180323180911.E43ACAB8@viggo.jf.intel.com>
 <CALvZod6F8x-smAE7sEGfJ3Ds5p6M5Qj6gd-P-VLejuBxfU6niQ@mail.gmail.com>
 <f7897068-18a3-d88b-0458-5dcf05d7ffc2@intel.com>
 <CALvZod7sqAo0jHwD3xgwJExR6=hRDnf1bYUEX5BMjp3gJnrVGQ@mail.gmail.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <9ef40243-3dc2-9bba-16b6-a94cffb57a24@intel.com>
Date: Fri, 23 Mar 2018 12:29:59 -0700
MIME-Version: 1.0
In-Reply-To: <CALvZod7sqAo0jHwD3xgwJExR6=hRDnf1bYUEX5BMjp3gJnrVGQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linuxram@us.ibm.com, Thomas Gleixner <tglx@linutronix.de>, mpe@ellerman.id.au, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, shuah@kernel.org

On 03/23/2018 12:27 PM, Shakeel Butt wrote:
> On Fri, Mar 23, 2018 at 12:23 PM, Dave Hansen <dave.hansen@intel.com> wrote:
>> On 03/23/2018 12:15 PM, Shakeel Butt wrote:
>>>> We had a check for PROT_READ/WRITE, but it did not work
>>>> for PROT_NONE.  This entirely removes the PROT_* checks,
>>>> which ensures that PROT_NONE now works.
>>>>
>>>> Reported-by: Shakeel Butt <shakeelb@google.com>
>>>> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
>>> Should there be a 'Fixes' tag? Also should this patch go to stable?
>> There could be, but I'm to lazy to dig up the original commit.  Does it
>> matter?
>>
> I think for stable 'Fixes' is usually preferable.

This one is a no-brainer.  If pkeys.c is there, it's necesary.

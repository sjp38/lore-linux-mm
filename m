Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id CA2FD6B002E
	for <linux-mm@kvack.org>; Fri, 23 Mar 2018 15:23:05 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id 69-v6so8188594plc.18
        for <linux-mm@kvack.org>; Fri, 23 Mar 2018 12:23:05 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id w9si4099758pfk.14.2018.03.23.12.23.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Mar 2018 12:23:04 -0700 (PDT)
Subject: Re: [PATCH 4/9] x86, pkeys: override pkey when moving away from
 PROT_EXEC
References: <20180323180903.33B17168@viggo.jf.intel.com>
 <20180323180911.E43ACAB8@viggo.jf.intel.com>
 <CALvZod6F8x-smAE7sEGfJ3Ds5p6M5Qj6gd-P-VLejuBxfU6niQ@mail.gmail.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <f7897068-18a3-d88b-0458-5dcf05d7ffc2@intel.com>
Date: Fri, 23 Mar 2018 12:23:02 -0700
MIME-Version: 1.0
In-Reply-To: <CALvZod6F8x-smAE7sEGfJ3Ds5p6M5Qj6gd-P-VLejuBxfU6niQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>, Dave Hansen <dave.hansen@linux.intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linuxram@us.ibm.com, Thomas Gleixner <tglx@linutronix.de>, mpe@ellerman.id.au, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, shuah@kernel.org

On 03/23/2018 12:15 PM, Shakeel Butt wrote:
>> We had a check for PROT_READ/WRITE, but it did not work
>> for PROT_NONE.  This entirely removes the PROT_* checks,
>> which ensures that PROT_NONE now works.
>>
>> Reported-by: Shakeel Butt <shakeelb@google.com>
>> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
> Should there be a 'Fixes' tag? Also should this patch go to stable?

There could be, but I'm to lazy to dig up the original commit.  Does it
matter?

And, yes, I think it probably makes sense for -stable.  I'll add that if
I resend this series.

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id F12966B0027
	for <linux-mm@kvack.org>; Fri, 23 Mar 2018 15:48:22 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id e7-v6so5940586plk.0
        for <linux-mm@kvack.org>; Fri, 23 Mar 2018 12:48:22 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id x190si6446250pgx.378.2018.03.23.12.48.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Mar 2018 12:48:22 -0700 (PDT)
Subject: Re: [PATCH 4/9] x86, pkeys: override pkey when moving away from
 PROT_EXEC
References: <20180323180903.33B17168@viggo.jf.intel.com>
 <20180323180911.E43ACAB8@viggo.jf.intel.com>
 <CALvZod6F8x-smAE7sEGfJ3Ds5p6M5Qj6gd-P-VLejuBxfU6niQ@mail.gmail.com>
 <f7897068-18a3-d88b-0458-5dcf05d7ffc2@intel.com>
 <alpine.DEB.2.21.1803232036140.1481@nanos.tec.linutronix.de>
 <alpine.DEB.2.21.1803232044350.1481@nanos.tec.linutronix.de>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <933dac0d-1be4-e952-7f53-0fa6d9169c9f@intel.com>
Date: Fri, 23 Mar 2018 12:48:20 -0700
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.21.1803232044350.1481@nanos.tec.linutronix.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Shakeel Butt <shakeelb@google.com>, Dave Hansen <dave.hansen@linux.intel.com>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linuxram@us.ibm.com, mpe@ellerman.id.au, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, shuah@kernel.org

On 03/23/2018 12:45 PM, Thomas Gleixner wrote:
>> The fixes tag makes sense in general even if the patch is not tagged for
>> stable. It gives you immediate context and I use it a lot to look why this
>> went unnoticed or what the context of that change was.
> That said, I'm even lazier than you and prefer you to dig up the original
> commit :)

I'll have these tags in the next repost.

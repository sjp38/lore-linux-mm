Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f42.google.com (mail-la0-f42.google.com [209.85.215.42])
	by kanga.kvack.org (Postfix) with ESMTP id 950216B00AE
	for <linux-mm@kvack.org>; Thu, 26 Jun 2014 18:19:48 -0400 (EDT)
Received: by mail-la0-f42.google.com with SMTP id pn19so2387026lab.1
        for <linux-mm@kvack.org>; Thu, 26 Jun 2014 15:19:47 -0700 (PDT)
Received: from mail-lb0-f169.google.com (mail-lb0-f169.google.com [209.85.217.169])
        by mx.google.com with ESMTPS id bm6si16715140lbb.30.2014.06.26.15.19.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 26 Jun 2014 15:19:47 -0700 (PDT)
Received: by mail-lb0-f169.google.com with SMTP id l4so3456213lbv.0
        for <linux-mm@kvack.org>; Thu, 26 Jun 2014 15:19:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <53AB42E1.4090102@intel.com>
References: <1403084656-27284-1-git-send-email-qiaowei.ren@intel.com>
 <1403084656-27284-3-git-send-email-qiaowei.ren@intel.com> <53A884B2.5070702@mit.edu>
 <53A88806.1060908@intel.com> <CALCETrXYZZiZsDiUvvZd0636+qHP9a0sHTN6wt_ZKjvLaeeBzw@mail.gmail.com>
 <53A88DE4.8050107@intel.com> <CALCETrWBbkFzQR3tz1TphqxiGYycvzrFrKc=ghzMynbem=d7rg@mail.gmail.com>
 <9E0BE1322F2F2246BD820DA9FC397ADE016AF41C@shsmsx102.ccr.corp.intel.com>
 <CALCETrX+iS5N8bCUm_O-1E4GPu4oG-SuFJoJjx_+S054K9-6pw@mail.gmail.com>
 <9E0BE1322F2F2246BD820DA9FC397ADE016B26AB@shsmsx102.ccr.corp.intel.com>
 <CALCETrWmmVC2qQtL0Js_Y7LvSPdTh5Hpk6c5ZG3Rt8uTJBWoHQ@mail.gmail.com>
 <CALCETrUD3L5Ta_v+NqgUrTk7Ok3zE=CRg0rqeKthOj2OORCLKQ@mail.gmail.com> <53AB42E1.4090102@intel.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Thu, 26 Jun 2014 15:19:26 -0700
Message-ID: <CALCETrVTTh9yuXH0hfcOpytyBd25K6thPfqqUBQtnOqx90ZRqw@mail.gmail.com>
Subject: Re: [PATCH v6 02/10] x86, mpx: add MPX specific mmap interface
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: "Ren, Qiaowei" <qiaowei.ren@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

On Wed, Jun 25, 2014 at 2:45 PM, Dave Hansen <dave.hansen@intel.com> wrote:
> On 06/25/2014 02:05 PM, Andy Lutomirski wrote:
>> Hmm.  the memfd_create thing may be able to do this for you.  If you
>> created a per-mm memfd and mapped it, it all just might work.
>
> memfd_create() seems to bring a fair amount of baggage along (the fd
> part :) if all we want is a marker.  Really, all we need is _a_ bit, and
> some way to plumb to userspace the RSS values of VMAs with that bit set.
>
> Creating and mmap()'ing a fd seems a rather roundabout way to get there.

Hmm.  So does VM_MPX, though.  If this stuff were done entirely in
userspace, then memfd_create would be exactly the right solution, I
think.

Would it work to just scan the bound directory to figure out how many
bound tables exist?

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

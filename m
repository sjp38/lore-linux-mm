Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 0658C6B003D
	for <linux-mm@kvack.org>; Fri, 27 Jun 2014 13:43:08 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id y10so4644908pdj.22
        for <linux-mm@kvack.org>; Fri, 27 Jun 2014 10:43:08 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id fl5si14657737pbb.220.2014.06.27.10.43.07
        for <linux-mm@kvack.org>;
        Fri, 27 Jun 2014 10:43:08 -0700 (PDT)
Message-ID: <53ADACF7.7080203@intel.com>
Date: Fri, 27 Jun 2014 10:42:15 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6 02/10] x86, mpx: add MPX specific mmap interface
References: <1403084656-27284-1-git-send-email-qiaowei.ren@intel.com> <53A884B2.5070702@mit.edu> <53A88806.1060908@intel.com> <CALCETrXYZZiZsDiUvvZd0636+qHP9a0sHTN6wt_ZKjvLaeeBzw@mail.gmail.com> <53A88DE4.8050107@intel.com> <CALCETrWBbkFzQR3tz1TphqxiGYycvzrFrKc=ghzMynbem=d7rg@mail.gmail.com> <9E0BE1322F2F2246BD820DA9FC397ADE016AF41C@shsmsx102.ccr.corp.intel.com> <CALCETrX+iS5N8bCUm_O-1E4GPu4oG-SuFJoJjx_+S054K9-6pw@mail.gmail.com> <9E0BE1322F2F2246BD820DA9FC397ADE016B26AB@shsmsx102.ccr.corp.intel.com> <CALCETrWmmVC2qQtL0Js_Y7LvSPdTh5Hpk6c5ZG3Rt8uTJBWoHQ@mail.gmail.com> <CALCETrUD3L5Ta_v+NqgUrTk7Ok3zE=CRg0rqeKthOj2OORCLKQ@mail.gmail.com> <53AB42E1.4090102@intel.com> <CALCETrVTTh9yuXH0hfcOpytyBd25K6thPfqqUBQtnOqx90ZRqw@mail.gmail.com> <53ACA5B3.3010702@intel.com> <CALCETrVceOhRunCg1b9Q3VL10Kcb+uA-HFUURnq5f2S63_jACg@mail.gmail.com> <53ACB8A7.9050002@intel.com> <CALCETrVR9QB3QvA2x_JjAXCFoqMw4B+byFTPDC3gQMUC1C-2NA@mail.gmail .com> <53ADAB39.6030403@intel.com>
In-Reply-To: <53ADAB39.6030403@intel.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: "Ren, Qiaowei" <qiaowei.ren@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

On 06/27/2014 10:34 AM, Dave Hansen wrote:
> I'm claiming that we need COW behavior for the bounds tables, at least
> by default.  If userspace knows enough about the ways that it is using
> the tables and knows how to share them, let it go to town.  The kernel
> will permit this kind of usage model, but we simply won't be helping
> with the management of the tables when userspace creates them.

Actually, this is another reason we need to mark VMAs as being
MPX-related explicitly instead of inferring it from the tables.  If
userspace does something really specialized like this, the kernel does
not want to confuse these VMAs the ones it created.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

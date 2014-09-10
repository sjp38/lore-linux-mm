Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 6FC776B0074
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 15:15:09 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id fp1so3996689pdb.15
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 12:15:09 -0700 (PDT)
Received: from mail.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id y3si29351235pda.0.2014.09.10.12.15.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Sep 2014 12:15:08 -0700 (PDT)
Message-ID: <5410A316.8090700@zytor.com>
Date: Wed, 10 Sep 2014 12:14:30 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 2/6] x86, mm, pat: Change reserve_memtype() to handle
 WT
References: <1410367910-6026-1-git-send-email-toshi.kani@hp.com> <1410367910-6026-3-git-send-email-toshi.kani@hp.com> <CALCETrXRjU3HvHogpm5eKB3Cogr5QHUvE67JOFGbOmygKYEGyA@mail.gmail.com>
In-Reply-To: <CALCETrXRjU3HvHogpm5eKB3Cogr5QHUvE67JOFGbOmygKYEGyA@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>, Toshi Kani <toshi.kani@hp.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Juergen Gross <jgross@suse.com>, Stefan Bader <stefan.bader@canonical.com>, Henrique de Moraes Holschuh <hmh@hmh.eng.br>, Yigal Korman <yigal@plexistor.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

On 09/10/2014 11:26 AM, Andy Lutomirski wrote:
> On Wed, Sep 10, 2014 at 9:51 AM, Toshi Kani <toshi.kani@hp.com> wrote:
>> This patch changes reserve_memtype() to handle the WT cache mode.
>> When PAT is not enabled, it continues to set UC- to *new_type for
>> any non-WB request.
>>
>> When a target range is RAM, reserve_ram_pages_type() fails for WT
>> for now.  This function may not reserve a RAM range for WT since
>> reserve_ram_pages_type() uses the page flags limited to three memory
>> types, WB, WC and UC.
> 
> Should it fail if WT is unavailable due to errata?  More generally,
> how are all of the do_something_wc / do_something_wt /
> do_something_nocache helpers supposed to handle unsupported types?
> 

Errata, or because it is pre-PAT hardware.  Keep in mind that even
pre-PAT hardware supports using page tables for cache types, it is only
that the only types supposed are WB, WT, UC.

	-hpa


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

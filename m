Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id D88D56B0036
	for <linux-mm@kvack.org>; Fri,  7 Mar 2014 12:19:14 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id ld10so4418459pab.12
        for <linux-mm@kvack.org>; Fri, 07 Mar 2014 09:19:14 -0800 (PST)
Received: from blackbird.sr71.net (www.sr71.net. [198.145.64.142])
        by mx.google.com with ESMTP id n8si8919424pab.290.2014.03.07.09.19.13
        for <linux-mm@kvack.org>;
        Fri, 07 Mar 2014 09:19:13 -0800 (PST)
Message-ID: <5319FF8D.1080107@sr71.net>
Date: Fri, 07 Mar 2014 09:19:09 -0800
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCH 5/7] x86: mm: new tunable for single vs full TLB flush
References: <20140306004519.BBD70A1A@viggo.jf.intel.com>	 <20140306004527.6C232C54@viggo.jf.intel.com> <1394156230.2555.19.camel@buesod1.americas.hpqcorp.net>
In-Reply-To: <1394156230.2555.19.camel@buesod1.americas.hpqcorp.net>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, ak@linux.intel.com, kirill.shutemov@linux.intel.com, mgorman@suse.de, alex.shi@linaro.org, x86@kernel.org, linux-mm@kvack.org, dave.hansen@linux.intel.com

On 03/06/2014 05:37 PM, Davidlohr Bueso wrote:
> On Wed, 2014-03-05 at 16:45 -0800, Dave Hansen wrote:
>> From: Dave Hansen <dave.hansen@linux.intel.com>
>> +
>> +If you believe that invlpg is being called too often, you can
>> +lower the tunable:
>> +
>> +	/sys/debug/kernel/x86/tlb_single_page_flush_ceiling
>> +
> 
> Whenever this tunable needs to be updated, most users will not know what
> a invlpg is and won't think in terms of pages either. How about making
> this in units of Kb instead? But then again most of those users won't be
> looking into tlb flushing issues anyways, so...

Yeah, talking about the instruction directly in the documentation is
probably going a bit far.  I'll see if I can uplevel it a bit.

It's obviously not a big deal to change it to be pages vs. kb, but for
something that's as *COMPLETELY* developer-focused, I think we can keep
it in pages.  We don't want users fooling with this.

> While obvious, tt should also mention that this does not apply to
> hugepages.

Good point.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 2DBB06B00BC
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 18:00:44 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id w10so6893479pde.26
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 15:00:43 -0700 (PDT)
Received: from mail.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id oz2si29248031pbc.237.2014.09.10.15.00.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Sep 2014 15:00:43 -0700 (PDT)
Message-ID: <5410C9F1.7030603@zytor.com>
Date: Wed, 10 Sep 2014 15:00:17 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 2/6] x86, mm, pat: Change reserve_memtype() to handle
 WT
References: <1410367910-6026-1-git-send-email-toshi.kani@hp.com>	 <1410367910-6026-3-git-send-email-toshi.kani@hp.com>	 <CALCETrXRjU3HvHogpm5eKB3Cogr5QHUvE67JOFGbOmygKYEGyA@mail.gmail.com>	 <1410377428.28990.260.camel@misato.fc.hp.com> <5410B10A.4030207@zytor.com>	 <1410381050.28990.295.camel@misato.fc.hp.com>	 <CALCETrUz016rDogLFTVETLh7ybVjgOMOhkL5kF2wJTLUF041xQ@mail.gmail.com>	 <1410383484.28990.303.camel@misato.fc.hp.com>	 <CALCETrV4DEr7tQUPCSzJMjBwgJ3-Xgcw8PFt_CCDbMoWRQ4Uug@mail.gmail.com>	 <5410C4F7.4080704@zytor.com> <1410385673.28990.313.camel@misato.fc.hp.com>
In-Reply-To: <1410385673.28990.313.camel@misato.fc.hp.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: Andy Lutomirski <luto@amacapital.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Juergen Gross <jgross@suse.com>, Stefan Bader <stefan.bader@canonical.com>, Henrique de Moraes Holschuh <hmh@hmh.eng.br>, Yigal Korman <yigal@plexistor.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

On 09/10/2014 02:47 PM, Toshi Kani wrote:
>>
>> Yes.  Don't think of it as PAT vs non-PAT.  Think of it as a specific
>> set of cache types available on different processors.  The fact that you
>> may have to frob an MSR to initialize it is almost trivial in comparison.
> 
> Right.
> 

In that sense the Xen "fixed PAT" fits right in.

	-hpa


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

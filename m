Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 13B056B0033
	for <linux-mm@kvack.org>; Wed, 11 Jan 2017 03:05:24 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id wr1so13483735wjc.7
        for <linux-mm@kvack.org>; Wed, 11 Jan 2017 00:05:24 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z31si3723336wrz.203.2017.01.11.00.05.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jan 2017 00:05:22 -0800 (PST)
Date: Wed, 11 Jan 2017 16:04:11 +0800
From: Dave Young <dyoung@redhat.com>
Subject: Re: [PATCH v2 2/2] efi: efi_mem_reserve(): don't reserve through
 memblock after mm_init()
Message-ID: <20170111080411.GA6381@dhcp-128-65.nay.redhat.com>
References: <20161222102340.2689-1-nicstange@gmail.com>
 <20161222102340.2689-2-nicstange@gmail.com>
 <20170105091242.GA11021@dhcp-128-65.nay.redhat.com>
 <20170109114400.GF16838@codeblueprint.co.uk>
 <20170110003735.GA2809@dhcp-128-65.nay.redhat.com>
 <20170110125150.GA31377@codeblueprint.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170110125150.GA31377@codeblueprint.co.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matt Fleming <matt@codeblueprint.co.uk>
Cc: Nicolai Stange <nicstange@gmail.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-efi@vger.kernel.org, linux-kernel@vger.kernel.org, Mika =?iso-8859-1?Q?Penttil=E4?= <mika.penttila@nextfour.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@techsingularity.net>

On 01/10/17 at 12:51pm, Matt Fleming wrote:
> On Tue, 10 Jan, at 08:37:35AM, Dave Young wrote:
> > 
> > It is true that it depends on acpi init, I was wondering if bgrt parsing can
> > be moved to early acpi code. But anyway I'm not sure it is doable and
> > worth.
> 
> That's a good question. I think I gave up last time I tried to move
> the BGRT code to early boot because of the dependencies involved with
> having the ACPI table parsing code initialised.
> 
> But if you want to take a crack at it, I'd be happy to review the
> patches.

Ok, I will have a try. 

Thanks
Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0F9A76B0038
	for <linux-mm@kvack.org>; Mon,  9 Jan 2017 08:45:05 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id s63so15047156wms.7
        for <linux-mm@kvack.org>; Mon, 09 Jan 2017 05:45:05 -0800 (PST)
Received: from mail-wm0-x22b.google.com (mail-wm0-x22b.google.com. [2a00:1450:400c:c09::22b])
        by mx.google.com with ESMTPS id x10si8280779wrc.249.2017.01.09.05.45.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Jan 2017 05:45:03 -0800 (PST)
Received: by mail-wm0-x22b.google.com with SMTP id c85so98397836wmi.1
        for <linux-mm@kvack.org>; Mon, 09 Jan 2017 05:45:03 -0800 (PST)
Date: Mon, 9 Jan 2017 13:45:02 +0000
From: Matt Fleming <matt@codeblueprint.co.uk>
Subject: Re: [PATCH v2 2/2] efi: efi_mem_reserve(): don't reserve through
 memblock after mm_init()
Message-ID: <20170109134502.GK16838@codeblueprint.co.uk>
References: <20161222102340.2689-1-nicstange@gmail.com>
 <20161222102340.2689-2-nicstange@gmail.com>
 <20170105091242.GA11021@dhcp-128-65.nay.redhat.com>
 <20170109114400.GF16838@codeblueprint.co.uk>
 <20170109133152.2izkcrzgzinxdwux@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170109133152.2izkcrzgzinxdwux@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Dave Young <dyoung@redhat.com>, Nicolai Stange <nicstange@gmail.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-efi@vger.kernel.org, linux-kernel@vger.kernel.org, Mika =?iso-8859-1?Q?Penttil=E4?= <mika.penttila@nextfour.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.cz>

On Mon, 09 Jan, at 01:31:52PM, Mel Gorman wrote:
> 
> Well, you could put in a __init global variable about availability into
> mm/memblock.c and then check it in memblock APIs like memblock_reserve()
> to BUG_ON? I know BUG_ON is frowned upon but this is not likely to be a
> situation that can be sensibly recovered.

Indeed. I've only ever seen this situation lead to silent memory
corruption and bitter tears.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

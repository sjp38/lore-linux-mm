Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 73A2F6B0389
	for <linux-mm@kvack.org>; Mon, 27 Feb 2017 16:57:48 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id v77so42231972wmv.5
        for <linux-mm@kvack.org>; Mon, 27 Feb 2017 13:57:48 -0800 (PST)
Received: from mail-wm0-x236.google.com (mail-wm0-x236.google.com. [2a00:1450:400c:c09::236])
        by mx.google.com with ESMTPS id e55si370wre.126.2017.02.27.13.57.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Feb 2017 13:57:47 -0800 (PST)
Received: by mail-wm0-x236.google.com with SMTP id u199so29769567wmd.1
        for <linux-mm@kvack.org>; Mon, 27 Feb 2017 13:57:47 -0800 (PST)
Date: Mon, 27 Feb 2017 21:57:45 +0000
From: Matt Fleming <matt@codeblueprint.co.uk>
Subject: Re: [PATCH v2 2/2] efi: efi_mem_reserve(): don't reserve through
 memblock after mm_init()
Message-ID: <20170227215745.GA28416@codeblueprint.co.uk>
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

What about something like this?

BUG_ON() shouldn't actually be necessary because I couldn't think of a
situation where A) memblock would be unavailable and B) returning an
error would prevent us from making progress.

---->8----

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4E37B6B0279
	for <linux-mm@kvack.org>; Thu, 22 Jun 2017 05:39:21 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id z1so2991109wrz.10
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 02:39:21 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 4si704569wmc.179.2017.06.22.02.39.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 22 Jun 2017 02:39:19 -0700 (PDT)
Date: Thu, 22 Jun 2017 11:39:05 +0200
From: Borislav Petkov <bp@suse.de>
Subject: Re: [PATCH] mm/hwpoison: Clear PRESENT bit for kernel 1:1 mappings
 of poison pages
Message-ID: <20170622093904.ajzoi43vlkejqgi3@pd.tnic>
References: <20170616190200.6210-1-tony.luck@intel.com>
 <20170619180147.qolal6mz2wlrjbxk@pd.tnic>
 <20170621174740.npbtg2e4o65tyrss@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170621174740.npbtg2e4o65tyrss@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Yazen Ghannam <yazen.ghannam@amd.com>

On Wed, Jun 21, 2017 at 10:47:40AM -0700, Luck, Tony wrote:
> I would if I could work out how to use it. From reading the manual
> page there seem to be a few options to this, but none of them appear
> to just drop a specific address (apart from my own). :-(

$ git send-email --to ... --cc ... --cc ... --suppress-cc=all ...

That should send only to the ones you have in --to and --cc and suppress
the rest.

Do a

$ git send-email -v --dry-run --to ... --cc ... --cc ... --suppress-cc=all ...

to see what it is going to do.

> I'd assume that other X86 implementations would face similar issues (unless
> they have extremely cautious pre-fetchers and/or no speculation).
> 
> I'm also assuming that non-X86 architectures that do recovery may want this
> too ... hence hooking the arch_unmap_kpfn() function into the generic
> memory_failure() code.

Which means that you could move the function to generic
mm/memory_failure.c code after making the decoy_addr computation
generic.

I'd still like to hear some sort of confirmation from other
vendors/arches whether it makes sense for them too, though.

I mean, if they don't do speculative accesses, then it probably doesn't
matter even - the page is innacessible anyway but still...

-- 
Regards/Gruss,
    Boris.

SUSE Linux GmbH, GF: Felix ImendA?rffer, Jane Smithard, Graham Norton, HRB 21284 (AG NA 1/4 rnberg)
-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7AE236B02C3
	for <linux-mm@kvack.org>; Fri, 30 Jun 2017 03:09:04 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id 4so37609174wrc.15
        for <linux-mm@kvack.org>; Fri, 30 Jun 2017 00:09:04 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q48si5386679wrb.280.2017.06.30.00.09.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 30 Jun 2017 00:09:03 -0700 (PDT)
Date: Fri, 30 Jun 2017 09:08:54 +0200
From: Borislav Petkov <bp@suse.de>
Subject: Re: git send-email (w/o Cc: stable)
Message-ID: <20170630070833.rwevr2yvp4wwo3ou@pd.tnic>
References: <20170616190200.6210-1-tony.luck@intel.com>
 <20170619180147.qolal6mz2wlrjbxk@pd.tnic>
 <20170621174740.npbtg2e4o65tyrss@intel.com>
 <20170622093904.ajzoi43vlkejqgi3@pd.tnic>
 <20170629221136.xbybfjb7tyloswf3@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170629221136.xbybfjb7tyloswf3@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Yazen Ghannam <yazen.ghannam@amd.com>, git@vger.kernel.org

On Thu, Jun 29, 2017 at 03:11:37PM -0700, Luck, Tony wrote:
> So there is a "--cc-cmd" option that can do the same as those "-cc" arguments.
> Combine that with --suppress-cc=bodycc and things get a bit more automated.

Yeah, whatever works for you.

I did play with cc-cmd somewhat but can't be bothered to generate the CC
list per hand each time.

I'd prefer if that switch:

	--suppress-cc=<category>

had the obvious <category> of single email address too:

	--suppress-cc=stable@vger.kernel.org

so that we can send patches and unconditionally suppress only that
single recipient from the CC list.

And maybe there is a way...

Let me CC the git ML.

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

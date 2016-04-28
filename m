Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id E8A346B025E
	for <linux-mm@kvack.org>; Thu, 28 Apr 2016 10:55:56 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id k200so74311976lfg.1
        for <linux-mm@kvack.org>; Thu, 28 Apr 2016 07:55:56 -0700 (PDT)
Received: from pandora.arm.linux.org.uk (pandora.arm.linux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id f141si16089860wmf.102.2016.04.28.07.55.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 28 Apr 2016 07:55:55 -0700 (PDT)
Date: Thu, 28 Apr 2016 15:55:45 +0100
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH 04/20] arm: get rid of superfluous __GFP_REPEAT
Message-ID: <20160428145545.GN19428@n2100.arm.linux.org.uk>
References: <1461849846-27209-1-git-send-email-mhocko@kernel.org>
 <1461849846-27209-5-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1461849846-27209-5-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, linux-arch@vger.kernel.org

On Thu, Apr 28, 2016 at 03:23:50PM +0200, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> __GFP_REPEAT has a rather weak semantic but since it has been introduced
> around 2.6.12 it has been ignored for low order allocations.
> 
> PGALLOC_GFP uses __GFP_REPEAT but none of the allocation which uses
> this flag is for more than order-2. This means that this flag has never
> been actually useful here because it has always been used only for
> PAGE_ALLOC_COSTLY requests.

I'm unconvinced.  Back in 2013, I was seeing a lot of failures, so:

commit 8c65da6dc89ccb605d73773b1dd617e72982d971
Author: Russell King <rmk+kernel@arm.linux.org.uk>
Date:   Sat Nov 30 12:52:31 2013 +0000

    ARM: pgd allocation: retry on failure

    Make pgd allocation retry on failure; we really need this to succeed
    otherwise fork() can trigger OOMs.

    Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>

Maybe something has changed again in the MM layer which makes this flag
unnecessary again, and it was a temporary blip around that time, I don't
know.

-- 
RMK's Patch system: http://www.arm.linux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1B9346B007E
	for <linux-mm@kvack.org>; Fri, 17 Jun 2016 14:27:55 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id l184so2733147lfl.3
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 11:27:55 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id d7si13370332wjc.145.2016.06.17.11.27.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Jun 2016 11:27:53 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id m124so1514553wme.3
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 11:27:53 -0700 (PDT)
Date: Fri, 17 Jun 2016 20:27:51 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/3] mm: Don't blindly assign fallback_migrate_page()
Message-ID: <20160617182751.GB692@dhcp22.suse.cz>
References: <1466112375-1717-1-git-send-email-richard@nod.at>
 <1466112375-1717-2-git-send-email-richard@nod.at>
 <20160616161121.35ee5183b9ef9f7b7dcbc815@linux-foundation.org>
 <5763A9B2.8060303@nod.at>
 <20160617162803.GK21670@dhcp22.suse.cz>
 <57642B91.4020206@nod.at>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <57642B91.4020206@nod.at>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Weinberger <richard@nod.at>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-mtd@lists.infradead.org, hannes@cmpxchg.org, mgorman@techsingularity.net, n-horiguchi@ah.jp.nec.com, kirill.shutemov@linux.intel.com, hughd@google.com, vbabka@suse.cz, adrian.hunter@intel.com, dedekind1@gmail.com, hch@infradead.org, linux-fsdevel@vger.kernel.org, boris.brezillon@free-electrons.com, maxime.ripard@free-electrons.com, david@sigma-star.at, david@fromorbit.com, alex@nextthing.co, sasha.levin@oracle.com, iamjoonsoo.kim@lge.com, rvaswani@codeaurora.org, tony.luck@intel.com, shailendra.capricorn@gmail.com

On Fri 17-06-16 18:55:45, Richard Weinberger wrote:
> Am 17.06.2016 um 18:28 schrieb Michal Hocko:
> > But doesn't this disable the page migration and so potentially reduce
> > the compaction success rate for the large pile of filesystems? Without
> > any hint about that?
> 
> The WARN_ON_ONCE() is the hint. ;)

Right. My reply turned a different way than I meant... I meant to say
that there might be different regressions caused by this change without much
hint that a particular warning would be the smoking gun... 
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

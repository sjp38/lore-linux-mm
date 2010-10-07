Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 2BE386B0085
	for <linux-mm@kvack.org>; Thu,  7 Oct 2010 04:58:37 -0400 (EDT)
Date: Thu, 7 Oct 2010 10:58:32 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 3/4] HWPOISON: Report correct address granuality for AO
 huge page errors
Message-ID: <20101007085832.GI5010@basil.fritz.box>
References: <1286398141-13749-1-git-send-email-andi@firstfloor.org>
 <1286398141-13749-4-git-send-email-andi@firstfloor.org>
 <20101007003120.GB9891@spritzera.linux.bs1.fc.nec.co.jp>
 <20101007073848.GG5010@basil.fritz.box>
 <20101007084101.GE9891@spritzera.linux.bs1.fc.nec.co.jp>
 <20101007084529.GH5010@basil.fritz.box>
 <20101007084837.GG9891@spritzera.linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101007084837.GG9891@spritzera.linux.bs1.fc.nec.co.jp>
Sender: owner-linux-mm@kvack.org
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, fengguang.wu@intel.com, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>
List-ID: <linux-mm.kvack.org>

> > I used compound_order(compound_head(page)) + PAGE_SHIFT now.
> > This even works for non compound, so the special case check
> > can be dropped.
> 
> OK.

BTW it would be nice if mce-test checked this for the huge page case too.
(I fixed this for small pages)

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

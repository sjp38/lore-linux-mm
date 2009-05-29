Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 672186B005C
	for <linux-mm@kvack.org>; Fri, 29 May 2009 02:21:37 -0400 (EDT)
Date: Fri, 29 May 2009 08:28:34 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [6/16] HWPOISON: Add basic support for poisoned pages in fault handler v2
Message-ID: <20090529062834.GN1065@one.firstfloor.org>
References: <200905271012.668777061@firstfloor.org> <20090527201232.555281D0290@basil.firstfloor.org> <4A1F6166.4020006@hitachi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4A1F6166.4020006@hitachi.com>
Sender: owner-linux-mm@kvack.org
To: Hidehiro Kawai <hidehiro.kawai.ez@hitachi.com>
Cc: Andi Kleen <andi@firstfloor.org>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com, Satoshi OSHIMA <satoshi.oshima.fk@hitachi.com>, Taketoshi Sakuraba <taketoshi.sakuraba.hc@hitachi.com>
List-ID: <linux-mm.kvack.org>

> Is this delayacct_clear_flag()? :-p

Hmpf.... Thanks. Fixed. Sorry about this.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

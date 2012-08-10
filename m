Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id DFD826B0044
	for <linux-mm@kvack.org>; Fri, 10 Aug 2012 19:13:04 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 3/3] HWPOISON: improve handling/reporting of memory error on dirty pagecache
References: <1344634913-13681-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	<1344634913-13681-4-git-send-email-n-horiguchi@ah.jp.nec.com>
Date: Fri, 10 Aug 2012 16:13:03 -0700
In-Reply-To: <1344634913-13681-4-git-send-email-n-horiguchi@ah.jp.nec.com>
	(Naoya Horiguchi's message of "Fri, 10 Aug 2012 17:41:53 -0400")
Message-ID: <m2628qcpds.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andi Kleen <andi.kleen@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, Rik van Riel <riel@redhat.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, Naoya Horiguchi <nhoriguc@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> writes:

> Current error reporting of memory errors on dirty pagecache has silent
> data lost problem because AS_EIO in struct address_space is cleared
> once checked.

Seems very complicated.  I think I would prefer something simpler
if possible, especially unless it's proven the case is common.
It's hard to maintain rarely used error code when it's complicated.
Maybe try Fengguang's simple proposal first? That would fix other IO
errors too.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

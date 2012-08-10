Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id EC6D86B0044
	for <linux-mm@kvack.org>; Fri, 10 Aug 2012 19:09:48 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 2/3] HWPOISON: undo memory error handling for dirty pagecache
References: <1344634913-13681-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	<1344634913-13681-3-git-send-email-n-horiguchi@ah.jp.nec.com>
Date: Fri, 10 Aug 2012 16:09:48 -0700
In-Reply-To: <1344634913-13681-3-git-send-email-n-horiguchi@ah.jp.nec.com>
	(Naoya Horiguchi's message of "Fri, 10 Aug 2012 17:41:52 -0400")
Message-ID: <m2a9y2cpj7.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andi Kleen <andi.kleen@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, Rik van Riel <riel@redhat.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, Naoya Horiguchi <nhoriguc@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> writes:

> Current memory error handling on dirty pagecache has a bug that user
> processes who use corrupted pages via read() or write() can't be aware
> of the memory error and result in discarding dirty data silently.
>
> The following patch is to improve handling/reporting memory errors on
> this case, but as a short term solution I suggest that we should undo
> the present error handling code and just leave errors for such cases
> (which expect the 2nd MCE to panic the system) to ensure data consistency.

Not sure that's the right approach. It's not worse than any other IO 
errors isn't it? 

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

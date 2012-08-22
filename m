Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 7DEBE6B0044
	for <linux-mm@kvack.org>; Wed, 22 Aug 2012 16:22:52 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 0/3 v2] HWPOISON: improve dirty pagecache error reporting
References: <1345648655-4497-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Date: Wed, 22 Aug 2012 13:22:36 -0700
In-Reply-To: <1345648655-4497-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	(Naoya Horiguchi's message of "Wed, 22 Aug 2012 11:17:32 -0400")
Message-ID: <m2obm27k37.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andi Kleen <andi.kleen@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, Rik van Riel <riel@redhat.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> writes:

> Hi,
>
> Based on the previous discussion, in this version I propose only error
> reporting fix ("overwrite recovery" is sparated out from this series.)
>
> I think Fengguang's patch (patch 2 in this series) has a corner case
> about inode cache drop, so I added patch 3 for it.

New patchkit looks very reasonable to me.

I haven't gone through all the corner cases the inode pinning may
have though. You probably want an review from Al Viro on this.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

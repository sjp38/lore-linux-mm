Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 4B1986B004D
	for <linux-mm@kvack.org>; Tue, 27 Nov 2012 16:08:40 -0500 (EST)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] mm, soft offline: split thp at the beginning of soft_offline_page()
References: <1354050331-26844-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Date: Tue, 27 Nov 2012 13:08:38 -0800
In-Reply-To: <1354050331-26844-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	(Naoya Horiguchi's message of "Tue, 27 Nov 2012 16:05:31 -0500")
Message-ID: <m2k3t6hhyh.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, Andi Kleen <andi.kleen@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> writes:

> When we try to soft-offline a thp tail page, put_page() is called on the
> tail page unthinkingly and VM_BUG_ON is triggered in put_compound_page().
> This patch splits thp before going into the main body of soft-offlining.

Looks good.

>
> The interface of soft-offlining is open for userspace, so this bug can
> lead to DoS attack and should be fixed immedately.

The interface is root only and root can do everything anyways, so it's
not really a security issue.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

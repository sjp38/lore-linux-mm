Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id B1DA76B0044
	for <linux-mm@kvack.org>; Sat, 11 Aug 2012 18:41:52 -0400 (EDT)
From: "Luck, Tony" <tony.luck@intel.com>
Subject: RE: [PATCH 3/3] HWPOISON: improve handling/reporting of memory
 error on dirty pagecache
Date: Sat, 11 Aug 2012 22:41:49 +0000
Message-ID: <3908561D78D1C84285E8C5FCA982C28F19375BFE@ORSMSX104.amr.corp.intel.com>
References: <1344634913-13681-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1344634913-13681-4-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1344634913-13681-4-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kleen, Andi" <andi.kleen@intel.com>, "Wu, Fengguang" <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, Naoya Horiguchi <nhoriguc@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

> dirty pagecache error recoverable under some conditions. Consider that
> if there is a copy of the corrupted dirty pagecache on user buffer and
> you write() over the error page with the copy data, then we can ignore
> the effect of the error because no one consumes the corrupted data.

This sounds like a quite rare corner case. If the page is already dirty, it=
 is
most likely because someone recently did a write(2) (or touched it via
mmap(2)). Now you are hoping that some process is going to write the
same page again.  Do you have an application in mind where this would
be common. Remember that the write(2), memory-error, new write(2)
have to happen close together (before Linux decides to write out the
dirty page).

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

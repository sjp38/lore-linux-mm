Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 948726B0044
	for <linux-mm@kvack.org>; Wed,  5 Dec 2012 17:05:17 -0500 (EST)
From: "Luck, Tony" <tony.luck@intel.com>
Subject: RE: [PATCH 3/3] HWPOISON, hugetlbfs: fix RSS-counter warning
Date: Wed, 5 Dec 2012 22:04:50 +0000
Message-ID: <3908561D78D1C84285E8C5FCA982C28F1C963B15@ORSMSX108.amr.corp.intel.com>
References: <1354744058-26373-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1354744058-26373-4-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1354744058-26373-4-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, "Kleen, Andi" <andi.kleen@intel.com>
Cc: "Wu, Fengguang" <fengguang.wu@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

	if (PageHWPoison(page) && !(flags & TTU_IGNORE_HWPOISON)) {
-		if (PageAnon(page))
+		if (PageHuge(page))
+			;
+		else if (PageAnon(page))
 			dec_mm_counter(mm, MM_ANONPAGES);
 		else
 			dec_mm_counter(mm, MM_FILEPAGES);

This style minimizes the "diff" ... but wouldn't it be nicer to say:

		if (!PageHuge(page)) {
			old code in here
		}

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

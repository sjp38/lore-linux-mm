Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 7CAAF6B0121
	for <linux-mm@kvack.org>; Tue, 30 Apr 2013 12:45:20 -0400 (EDT)
Date: Tue, 30 Apr 2013 12:45:03 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v2] hugetlbfs: fix mmap failure in unaligned size request
Message-ID: <20130430164502.GD1229@cmpxchg.org>
References: <bug-56881-27@https.bugzilla.kernel.org/>
 <20130423132522.042fa8d27668bbca6a410a92@linux-foundation.org>
 <20130424081454.GA13994@cmpxchg.org>
 <1366816599-7fr82iw1-mutt-n-horiguchi@ah.jp.nec.com>
 <20130424153951.GQ2018@cmpxchg.org>
 <1366844735-kqynvvnu-mutt-n-horiguchi@ah.jp.nec.com>
 <20130424232600.GB18686@cmpxchg.org>
 <1366923617-dvp2vbsx-mutt-n-horiguchi@ah.jp.nec.com>
 <1366950912-u5c1huyl-mutt-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1366950912-u5c1huyl-mutt-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, iceman_dvd@yahoo.com, Steven Truelove <steven.truelove@utoronto.ca>, Jianguo Wu <wujianguo@huawei.com>

On Fri, Apr 26, 2013 at 12:35:12AM -0400, Naoya Horiguchi wrote:
> Here is a revised patch.
> Thank you for the nice feedback, Johannes, Jianguo.

FWIW, this looks good to me.  Could you include

Reported-by: iceman_dvd@yahoo.com

and resend it to Andrew?  Unless Andrew sees and picks it directly
from this thread.  Hi, Andrew!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

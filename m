Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id D18016B004D
	for <linux-mm@kvack.org>; Fri, 20 Jul 2012 10:36:39 -0400 (EDT)
Date: Fri, 20 Jul 2012 16:36:35 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH -alternative] mm: hugetlbfs: Close race during teardown of
 hugetlbfs shared page tables V2 (resend)
Message-ID: <20120720143635.GE12434@tiehlicka.suse.cz>
References: <20120720134937.GG9222@suse.de>
 <20120720141108.GH9222@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120720141108.GH9222@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>, David Gibson <david@gibson.dropbear.id.au>, Ken Chen <kenchen@google.com>, Cong Wang <xiyou.wangcong@gmail.com>, LKML <linux-kernel@vger.kernel.org>

And here is my attempt for the fix (Hugh mentioned something similar
earlier but he suggested using special flags in ptes or VMAs). I still
owe doc. update and it hasn't been tested with too many configs and I
could missed some definition updates.
I also think that changelog could be much better, I will add (steal) the
full bug description if people think that this way is worth going rather
than the one suggested by Mel.
To be honest I am not quite happy how I had to pollute generic mm code with
something that is specific to a single architecture.
Mel hammered it with the test case and it survived.
---

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 5BB666B005A
	for <linux-mm@kvack.org>; Tue, 21 Aug 2012 17:46:37 -0400 (EDT)
Date: Tue, 21 Aug 2012 14:46:36 -0700
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [PATCH 0/5] Memory policy corruption fixes V2
Message-ID: <20120821214636.GA12707@tassilo.jf.intel.com>
References: <1345480594-27032-1-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1345480594-27032-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Jones <davej@redhat.com>, Christoph Lameter <cl@linux.com>, Ben Hutchings <ben@decadent.org.uk>, Hugh Dickins <hughd@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

> I tested this with trinity with CONFIG_DEBUG_SLAB enabled and it passed. I
> did not test LTP such as Josh reported a problem with or with a database that
> used shared policies like Andi tested. The series is almost all Kosaki's
> work of course. If he has a revised series that simply got delayed in
> posting it should take precedence.

Initial tests of this patchkit look with a test programgood, full database tests 
are still pending.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

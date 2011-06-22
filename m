Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 1A5FB6B024E
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 23:13:46 -0400 (EDT)
Message-ID: <4E015DCA.8040204@redhat.com>
Date: Wed, 22 Jun 2011 11:13:14 +0800
From: Cong Wang <amwang@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/4] mm: introduce no_ksm to disable totally KSM
References: <1308643849-3325-1-git-send-email-amwang@redhat.com> <1308643849-3325-4-git-send-email-amwang@redhat.com> <20110621133236.GP20843@redhat.com>
In-Reply-To: <20110621133236.GP20843@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org

ao? 2011a1'06ae??21ae?JPY 21:32, Andrea Arcangeli a??e??:
> On Tue, Jun 21, 2011 at 04:10:45PM +0800, Amerigo Wang wrote:
>> Introduce a new kernel parameter "no_ksm" to totally disable KSM.
>
> Here as well this is the wrong approach. If you want to save memory,
> you should make ksmd quit when run=0 and start only when setting
> ksm/run=1. And move the daemon hashes and slabs initializations to the
> ksmd daemon start. Not registering in sysfs and crippling down the
> feature despite you loaded the proper .text into memory isn't good.

1. Not only about saving memory, as I explained in other thread.

2. Recompiling kernel is not always acceptable, as I replied in other thread.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

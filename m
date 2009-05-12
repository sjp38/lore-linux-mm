Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 8BD856B009D
	for <linux-mm@kvack.org>; Tue, 12 May 2009 16:17:32 -0400 (EDT)
Message-ID: <4A09D957.2070908@redhat.com>
Date: Tue, 12 May 2009 16:17:27 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm] vmscan: protect a fraction of file backed mapped
 pages from reclaim
References: <20090508125859.210a2a25.akpm@linux-foundation.org> <20090512025246.GC7518@localhost> <20090512120002.D616.A69D9226@jp.fujitsu.com> <alpine.DEB.1.10.0905121650090.14226@qirst.com> <4A09AC91.4060506@redhat.com> <alpine.DEB.1.10.0905121718040.24066@qirst.com> <4A09B46D.9010705@redhat.com> <alpine.DEB.1.10.0905121801080.19973@qirst.com>
In-Reply-To: <alpine.DEB.1.10.0905121801080.19973@qirst.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "peterz@infradead.org" <peterz@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Tue, 12 May 2009, Rik van Riel wrote:
> 
>>> Streaming I/O means access once?
>> Yeah, "used-once pages" would be a better criteria, since
>> you could go through a gigantic set of used-once pages without
>> doing linear IO.
> 
> Can we see some load for which this patch has a beneficial effect?
> With some numbers?

How many do you want before you're satisfied that this
benefits a significant number of workloads?

How many numbers do you want to feel safe that no workloads
suffer badly from this patch?

Also, wow would you measure a concept as nebulous as desktop
interactivity?

Btw, the patch has gone into the Fedora kernel RPM to get
a good amount of user testing.  I'll let you know what the
users say (if anything).

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

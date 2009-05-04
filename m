Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 068A96B00A2
	for <linux-mm@kvack.org>; Mon,  4 May 2009 10:39:41 -0400 (EDT)
Received: by yx-out-1718.google.com with SMTP id 36so2106225yxh.26
        for <linux-mm@kvack.org>; Mon, 04 May 2009 07:40:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090502024719.GA29730@localhost>
References: <200904302208.n3UM8t9R016687@imap1.linux-foundation.org>
	 <20090501012212.GA5848@localhost>
	 <20090430194907.82b31565.akpm@linux-foundation.org>
	 <20090502023125.GA29674@localhost> <20090502024719.GA29730@localhost>
Date: Mon, 4 May 2009 23:40:18 +0900
Message-ID: <2f11576a0905040740m779464fdobd435a9b88a4ae67@mail.gmail.com>
Subject: Re: [RFC][PATCH] vmscan: don't export nr_saved_scan in /proc/zoneinfo
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>, "lee.schermerhorn@hp.com" <lee.schermerhorn@hp.com>, "peterz@infradead.org" <peterz@infradead.org>, "riel@redhat.com" <riel@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> The lru->nr_saved_scan's are not meaningful counters for even kernel
> developers. =A0They typically are smaller than 32 and are always 0 for
> large lists. So remove them from /proc/zoneinfo.
>
> Hopefully this interface change won't break too many scripts.
> /proc/zoneinfo is too unstructured to be script friendly, and I wonder
> the affected scripts - if there are any - are still bleeding since the
> not long ago commit "vmscan: split LRU lists into anon & file sets",
> which also touched the "scanned" line :)
>
> If we are to re-export accumulated vmscan counts in the future, they
> can go to new lines in /proc/zoneinfo instead of the current form, or
> to /sys/devices/system/node/node0/meminfo?
>
> CC: Christoph Lameter <cl@linux-foundation.org>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>

 Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

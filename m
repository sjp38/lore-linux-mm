Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 9D3B86B004D
	for <linux-mm@kvack.org>; Mon, 19 Dec 2011 16:24:00 -0500 (EST)
Date: Mon, 19 Dec 2011 22:23:48 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC][PATCH 2/3] pagemap: export KPF_THP
Message-ID: <20111219212348.GP16411@redhat.com>
References: <1324319919-31720-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1324319919-31720-3-git-send-email-n-horiguchi@ah.jp.nec.com>
 <4EEF8F85.9010408@gmail.com>
 <4EEF9F3E.9000107@linux.vnet.ibm.com>
 <4EEFA278.7010200@gmail.com>
 <4EEFA51D.2050707@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4EEFA51D.2050707@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org

On Mon, Dec 19, 2011 at 12:57:01PM -0800, Dave Hansen wrote:
> But, every single one of the pagemap flags is really just a snapshot
> KPF_DIRTY, KPF_LOCKED, etc...  The entire interface is inherently a racy
> snapshot, and there's not a whole lot you can do about it.

Having read the discussion, while I don't see a big need of the
KPF_THP, I also see how it in certain corner cases it can be used to
test memory failure injection and I agree with you on the above. Maybe
it can also be used to check if at certain virtual offsets
(pid/pagemap lookup followed by a kpageflags lookup) we always fail to
find THP inside big vmas, maybe out of not aligned mprotect that may
be optimized by aligning it.

The other kernel internal bits may also be stale and go away quicker
than the KPF_THP, so I don't see a problem in exposing it. We also
provide THP related info in meminfo/smaps, if they were supposed to be
invisible that wouldn't be allowed too.

A bigger concern to me is that the new bitfield alters the protocol,
but old code by adding one more bit (if sanely coded...) shouldn't break.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

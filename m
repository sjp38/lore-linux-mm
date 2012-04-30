Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id C2F376B0044
	for <linux-mm@kvack.org>; Mon, 30 Apr 2012 18:12:38 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH bugfix] proc/pagemap: correctly report non-present ptes and holes between vmas
Date: Mon, 30 Apr 2012 18:12:14 -0400
Message-Id: <1335823934-25154-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <4F9EE5BF.9070005@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: khlebnikov@openvz.org
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, ak@linux.intel.com, xemul@parallels.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Mon, Apr 30, 2012 at 11:19:27PM +0400, Konstantin Khlebnikov wrote:
> Naoya Horiguchi wrote:
> >Hi,
> >
> >On Sat, Apr 28, 2012 at 08:22:30PM +0400, Konstantin Khlebnikov wrote:
> >>This patch resets current pagemap-entry if current pte isn't present,
> >>or if current vma is over. Otherwise pagemap reports last entry again and again.
> >>
> >>non-present pte reporting was broken in commit v3.3-3738-g092b50b
> >>("pagemap: introduce data structure for pagemap entry")
> >>
> >>reporting for holes was broken in commit v3.3-3734-g5aaabe8
> >>("pagemap: avoid splitting thp when reading /proc/pid/pagemap")
> >>
> >>Signed-off-by: Konstantin Khlebnikov<khlebnikov@openvz.org>
> >>Reported-by: Pavel Emelyanov<xemul@parallels.com>
> >>Cc: Naoya Horiguchi<n-horiguchi@ah.jp.nec.com>
> >>Cc: KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
> >>Cc: Andi Kleen<ak@linux.intel.com>
> >
> >Thanks for your efforts.
> >I confirmed that this patch fixes the problem on v3.4-rc4.
> >But originally (before the commits you pointed to above) initializing
> >pagemap entries (originally labelled with confusing 'pfn') were done
> >in for-loop in pagemap_pte_range(), so I think it's better to get it
> >back to things like that.
> >
> >How about the following?
> 
> I don't like this. Functions which returns void should always initialize its "output"
> argument, it much more clear than relying on preinitialized value.

OK, it makes sense.

Thanks,
Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

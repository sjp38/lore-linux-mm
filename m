Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 3B02D6B0083
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 15:38:20 -0500 (EST)
Date: Wed, 29 Feb 2012 12:38:18 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH resend] mm: drain percpu lru add/rotate page-vectors on
 cpu hot-unplug
Message-Id: <20120229123818.61a61e9d.akpm@linux-foundation.org>
In-Reply-To: <20120228193620.32063.83425.stgit@zurg>
References: <20120228193620.32063.83425.stgit@zurg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Tue, 28 Feb 2012 23:40:45 +0400
Konstantin Khlebnikov <khlebnikov@openvz.org> wrote:

> This cpu hotplug hook was accidentally removed in commit v2.6.30-rc4-18-g00a62ce
> ("mm: fix Committed_AS underflow on large NR_CPUS environment")

That was a long time ago - maybe we should leave it removed ;) I mean,
did this bug(?) have any visible effect?  If so, what was that effect?

IOW, the changelog didn't give anyone any reason to apply the patch to
anything!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

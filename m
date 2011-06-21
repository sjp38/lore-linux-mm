Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id A69AE9000BD
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 23:36:09 -0400 (EDT)
Message-ID: <4E0011A0.4070401@redhat.com>
Date: Tue, 21 Jun 2011 11:36:00 +0800
From: Cong Wang <amwang@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] mm: completely disable THP by transparent_hugepage=never
References: <1308587683-2555-1-git-send-email-amwang@redhat.com> <20110620165844.GA9396@suse.de> <4DFF7E3B.1040404@redhat.com> <4DFF7F0A.8090604@redhat.com> <4DFF8106.8090702@redhat.com> <4DFF8327.1090203@redhat.com> <4DFF84BB.3050209@redhat.com> <20110620175859.GB9697@mgebm.net>
In-Reply-To: <20110620175859.GB9697@mgebm.net>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@mgebm.net>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

ao? 2011a1'06ae??21ae?JPY 01:58, Eric B Munson a??e??:
> If memory is this scarce, why not set CONFIG_TRANSPARENT_HUGEPAGE=n and be done
> with it?  If the config option is enabled, the admin should be able to turn the
> functionality back on if desired.  If you really don't _ever_ want THP then
> disable the config.
>

Unfortunately, changing .config is not always as easy as you said,
for the kdump case, we use the same kernel binary with the normal kernel
which certainly has to have THP enabled in .config.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

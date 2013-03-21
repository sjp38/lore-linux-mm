Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 8D6306B0002
	for <linux-mm@kvack.org>; Thu, 21 Mar 2013 15:48:33 -0400 (EDT)
Message-ID: <514B63C2.5020809@redhat.com>
Date: Thu, 21 Mar 2013 15:47:14 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 08/10] mm: vmscan: Have kswapd shrink slab only once per
 priority
References: <1363525456-10448-1-git-send-email-mgorman@suse.de> <1363525456-10448-9-git-send-email-mgorman@suse.de>
In-Reply-To: <1363525456-10448-9-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Satoru Moriya <satoru.moriya@hds.com>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>

On 03/17/2013 09:04 AM, Mel Gorman wrote:
> If kswaps fails to make progress but continues to shrink slab then it'll
> either discard all of slab or consume CPU uselessly scanning shrinkers.
> This patch causes kswapd to only call the shrinkers once per priority.
>
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Acked-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

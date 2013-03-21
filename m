Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 07E5A6B0002
	for <linux-mm@kvack.org>; Thu, 21 Mar 2013 15:53:50 -0400 (EDT)
Message-ID: <514B6501.80102@redhat.com>
Date: Thu, 21 Mar 2013 15:52:33 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 09/10] mm: vmscan: Check if kswapd should writepage once
 per priority
References: <1363525456-10448-1-git-send-email-mgorman@suse.de> <1363525456-10448-10-git-send-email-mgorman@suse.de>
In-Reply-To: <1363525456-10448-10-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Satoru Moriya <satoru.moriya@hds.com>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>

On 03/17/2013 09:04 AM, Mel Gorman wrote:
> Currently kswapd checks if it should start writepage as it shrinks
> each zone without taking into consideration if the zone is balanced or
> not. This is not wrong as such but it does not make much sense either.
> This patch checks once per priority if kswapd should be writing pages.
>
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Acked-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

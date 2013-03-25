Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 51F846B004D
	for <linux-mm@kvack.org>; Mon, 25 Mar 2013 04:17:26 -0400 (EDT)
Date: Mon, 25 Mar 2013 09:17:23 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC PATCH 0/8] Reduce system disruption due to kswapd
Message-ID: <20130325081717.GA2154@dhcp22.suse.cz>
References: <1363525456-10448-1-git-send-email-mgorman@suse.de>
 <514F4D37.5030304@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <514F4D37.5030304@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Slaby <jslaby@suse.cz>
Cc: Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Satoru Moriya <satoru.moriya@hds.com>, LKML <linux-kernel@vger.kernel.org>

On Sun 24-03-13 20:00:07, Jiri Slaby wrote:
[...]
> Hi,
> 
> patch 1 does not apply (on the top of -next), so I can't test this :(.

It conflicts with (mm/vmscan.c: minor cleanup for kswapd). The one below
should apply
---

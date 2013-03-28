Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 2B81F6B0002
	for <linux-mm@kvack.org>; Thu, 28 Mar 2013 18:31:23 -0400 (EDT)
Received: by mail-ee0-f44.google.com with SMTP id l10so11039eei.17
        for <linux-mm@kvack.org>; Thu, 28 Mar 2013 15:31:21 -0700 (PDT)
Message-ID: <5154C4B6.102@suse.cz>
Date: Thu, 28 Mar 2013 23:31:18 +0100
From: Jiri Slaby <jslaby@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 01/10] mm: vmscan: Limit the number of pages kswapd reclaims
 at each priority
References: <1363525456-10448-1-git-send-email-mgorman@suse.de> <1363525456-10448-2-git-send-email-mgorman@suse.de> <20130325090758.GO2154@dhcp22.suse.cz> <51501545.50908@suse.cz>
In-Reply-To: <51501545.50908@suse.cz>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Satoru Moriya <satoru.moriya@hds.com>, LKML <linux-kernel@vger.kernel.org>

On 03/25/2013 10:13 AM, Jiri Slaby wrote:
> BTW I very pray this will fix also the issue I have when I run ltp tests
> (highly I/O intensive, esp. `growfiles') in a VM while playing a movie
> on the host resulting in a stuttered playback ;).

No, this is still terrible. I was now updating a kernel in a VM and had
problems to even move with cursor. There was still 1.2G used by I/O cache.

thanks,
-- 
js
suse labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

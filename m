Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f171.google.com (mail-ea0-f171.google.com [209.85.215.171])
	by kanga.kvack.org (Postfix) with ESMTP id 8BD446B0035
	for <linux-mm@kvack.org>; Tue, 17 Dec 2013 10:07:38 -0500 (EST)
Received: by mail-ea0-f171.google.com with SMTP id h10so2968949eak.30
        for <linux-mm@kvack.org>; Tue, 17 Dec 2013 07:07:37 -0800 (PST)
Received: from bitsync.net (bitsync.net. [80.83.126.10])
        by mx.google.com with ESMTP id e2si5346607eeg.30.2013.12.17.07.07.37
        for <linux-mm@kvack.org>;
        Tue, 17 Dec 2013 07:07:37 -0800 (PST)
Message-ID: <52B068B7.4070304@bitsync.net>
Date: Tue, 17 Dec 2013 16:07:35 +0100
From: Zlatko Calusic <zcalusic@bitsync.net>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 0/7] Configurable fair allocation zone policy v2r6
References: <1386943807-29601-1-git-send-email-mgorman@suse.de>
In-Reply-To: <1386943807-29601-1-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 13.12.2013 15:10, Mel Gorman wrote:
> Kicked this another bit today. It's still a bit half-baked but it restores
> the historical performance and leaves the door open at the end for playing
> nice with distributing file pages between nodes. Finishing this series
> depends on whether we are going to make the remote node behaviour of the
> fair zone allocation policy configurable or redefine MPOL_LOCAL. I'm in
> favour of the configurable option because the default can be redefined and
> tested while giving users a "compat" mode if we discover the new default
> behaviour sucks for some workload.
>

I'll start a 5-day test of this patchset in a few hours, unless you can 
send an updated one in the meantime. I intend to test it on a rather 
boring 4GB x86_64 machine that before Johannes' work had lots of trouble 
balancing zones. Would you recommend to use the default settings, i.e. 
don't mess with tunables at this point?

Regards,
-- 
Zlatko

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 87ED66B0044
	for <linux-mm@kvack.org>; Mon, 26 Nov 2012 10:32:24 -0500 (EST)
Message-ID: <50B38B7C.2080201@redhat.com>
Date: Mon, 26 Nov 2012 10:32:12 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm,vmscan: only loop back if compaction would fail in
 all zones
References: <20121119202152.4B0E420004E@hpza10.eem.corp.google.com> <20121125175728.3db4ac6a@fem.tu-ilmenau.de> <20121125132950.11b15e38@annuminas.surriel.com> <20121125224433.GB2799@cmpxchg.org> <20121125191645.0ebc6d59@annuminas.surriel.com> <20121126031518.GC2799@cmpxchg.org> <20121126041041.GD2799@cmpxchg.org>
In-Reply-To: <20121126041041.GD2799@cmpxchg.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Johannes Hirte <johannes.hirte@fem.tu-ilmenau.de>, akpm@linux-foundation.org, mgorman@suse.de, Valdis.Kletnieks@vt.edu, jirislaby@gmail.com, jslaby@suse.cz, zkabelac@redhat.com, mm-commits@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

On 11/25/2012 11:10 PM, Johannes Weiner wrote:

> From: Johannes Weiner <hannes@cmpxchg.org>
> Subject: [patch] mm: vmscan: fix endless loop in kswapd balancing
>
> Kswapd does not in all places have the same criteria for when it
> considers a zone balanced.  This leads to zones being not reclaimed
> because they are considered just fine and the compaction checks to
> loop over the zonelist again because they are considered unbalanced,
> causing kswapd to run forever.
>
> Add a function, zone_balanced(), that checks the watermark and if
> compaction has enough free memory to do its job.  Then use it
> uniformly for when kswapd needs to check if a zone is balanced.
>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Reviewed-by: Rik van Riel <riel@redhat.com>


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

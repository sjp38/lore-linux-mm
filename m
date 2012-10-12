Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 3C6F56B0068
	for <linux-mm@kvack.org>; Fri, 12 Oct 2012 08:38:01 -0400 (EDT)
Received: by mail-we0-f169.google.com with SMTP id u3so1949726wey.14
        for <linux-mm@kvack.org>; Fri, 12 Oct 2012 05:38:00 -0700 (PDT)
Message-ID: <50780F26.7070007@suse.cz>
Date: Fri, 12 Oct 2012 14:37:58 +0200
From: Jiri Slaby <jslaby@suse.cz>
MIME-Version: 1.0
Subject: Re: kswapd0: excessive CPU usage
References: <507688CC.9000104@suse.cz> <106695.1349963080@turing-police.cc.vt.edu> <5076E700.2030909@suse.cz> <118079.1349978211@turing-police.cc.vt.edu>            <50770905.5070904@suse.cz> <119175.1349979570@turing-police.cc.vt.edu> <5077434D.7080008@suse.cz>
In-Reply-To: <5077434D.7080008@suse.cz>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Valdis.Kletnieks@vt.edu
Cc: Jiri Slaby <jirislaby@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.com>, Andrew Morton <akpm@linux-foundation.org>

On 10/12/2012 12:08 AM, Jiri Slaby wrote:
> (It's an effective revert of "mm: vmscan: scale number of pages
> reclaimed by reclaim/compaction based on failures".)

Given kswapd had hours of runtime in ps/top output yesterday in the
morning and after the revert it's now 2 minutes in sum for the last 24h,
I would say, it's gone.

Mel, you wrote me it's unlikely the patch, but not impossible in the
end. Can you take a look, please? If you need some trace-cmd output or
anything, just let us know.

This is x86_64, 6G of RAM, no swap. FWIW EXT4, SLUB, COMPACTION all
enabled/used.

thanks,
-- 
js
suse labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

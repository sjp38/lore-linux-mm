Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id ECB496B004D
	for <linux-mm@kvack.org>; Mon,  3 Dec 2012 08:14:10 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id d41so1928575eek.14
        for <linux-mm@kvack.org>; Mon, 03 Dec 2012 05:14:09 -0800 (PST)
Message-ID: <50BCA59D.6040704@suse.cz>
Date: Mon, 03 Dec 2012 14:14:05 +0100
From: Jiri Slaby <jslaby@suse.cz>
MIME-Version: 1.0
Subject: Re: kswapd craziness in 3.7
References: <1354049315-12874-1-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1354049315-12874-1-git-send-email-hannes@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, George Spelvin <linux@horizon.com>, Johannes Hirte <johannes.hirte@fem.tu-ilmenau.de>, Tomas Racek <tracek@redhat.com>, Jan Kara <jack@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Josh Boyer <jwboyer@gmail.com>, Valdis.Kletnieks@vt.edu, Thorsten Leemhuis <fedora@leemhuis.info>, Zdenek Kabelac <zkabelac@redhat.com>, Bruno Wolff III <bruno@wolff.to>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 11/27/2012 09:48 PM, Johannes Weiner wrote:
> I hope I included everybody that participated in the various threads
> on kswapd getting stuck / exhibiting high CPU usage.  We were looking
> at at least three root causes as far as I can see, so it's not really
> clear who observed which problem.  Please correct me if the
> reported-by, tested-by, bisected-by tags are incomplete.

Hi, I reported the problem for the first time but I got lost in the
patches flying around very early.

Whatever is in the current -next, works for me since -next was
resurrected after the 2 weeks gap last week...

thanks,
-- 
js
suse labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Message-Id: <20081009155039.139856823@suse.de>
Date: Fri, 10 Oct 2008 02:50:39 +1100
From: npiggin@suse.de
Subject: [patch 0/8] write_cache_pages fixes
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mikulas Patocka <mpatocka@redhat.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

OK, here is a submission for the bugs and small improvements I saw for
write_cache_pages. This does not include any work on the "livelock" issue
(which Mikulas and myself have different approaches to fix), but I think
these patches should go in first because they're fixing actual hard bugs
(and just a couple of minor improvements).  

I've given it some testing, but there are so many combinations of behaviours
here, that I'd like some fsdevel people to look over it (eg. I didn't test
with an AOP_WRITEPAGE_TRUNCATE filesystem, or a range_cyclic one).

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

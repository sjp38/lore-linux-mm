Date: Mon, 24 Sep 2007 14:02:58 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm 4/5] mm: test and set zone reclaim lock before starting
 reclaim
In-Reply-To: <alpine.DEB.0.9999.0709241211240.16397@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.0.9999.0709241402480.22430@chino.kir.corp.google.com>
References: <alpine.DEB.0.9999.0709212311130.13727@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709212312160.13727@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709212312400.13727@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709212312560.13727@chino.kir.corp.google.com>
 <Pine.LNX.4.64.0709241202280.29673@schroedinger.engr.sgi.com> <alpine.DEB.0.9999.0709241211240.16397@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Add newlines between new zone flag tester/modifier functions.

Cc: Christoph Lameter <clameter@sgi.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 include/linux/mmzone.h |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -320,10 +320,12 @@ static inline void zone_set_flag(struct zone *zone, zone_flags_t flag)
 {
 	set_bit(flag, &zone->flags);
 }
+
 static inline int zone_test_and_set_flag(struct zone *zone, zone_flags_t flag)
 {
 	return test_and_set_bit(flag, &zone->flags);
 }
+
 static inline void zone_clear_flag(struct zone *zone, zone_flags_t flag)
 {
 	clear_bit(flag, &zone->flags);
@@ -333,10 +335,12 @@ static inline int zone_is_all_unreclaimable(const struct zone *zone)
 {
 	return test_bit(ZONE_ALL_UNRECLAIMABLE, &zone->flags);
 }
+
 static inline int zone_is_reclaim_locked(const struct zone *zone)
 {
 	return test_bit(ZONE_RECLAIM_LOCKED, &zone->flags);
 }
+
 static inline int zone_is_oom_locked(const struct zone *zone)
 {
 	return test_bit(ZONE_OOM_LOCKED, &zone->flags);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

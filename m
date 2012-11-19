Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 52AA36B0078
	for <linux-mm@kvack.org>; Mon, 19 Nov 2012 00:32:04 -0500 (EST)
From: Josh Triplett <josh@joshtriplett.org>
Subject: [PATCH 43/58] mm: Mark fallback version of __early_pfn_to_nid static
Date: Sun, 18 Nov 2012 21:28:22 -0800
Message-Id: <1353302917-13995-44-git-send-email-josh@joshtriplett.org>
In-Reply-To: <1353302917-13995-1-git-send-email-josh@joshtriplett.org>
References: <1353302917-13995-1-git-send-email-josh@joshtriplett.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Josh Triplett <josh@joshtriplett.org>

mm/page_alloc.c defines a fallback version of __early_pfn_to_nid for
architectures without CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID.  Nothing
outside of mm/page_alloc.c calls that function, so mark it static.  This
eliminates warnings from GCC (-Wmissing-prototypes) and Sparse (-Wdecl).

mm/page_alloc.c:4075:118: warning: no previous prototype for =E2=80=98__e=
arly_pfn_to_nid=E2=80=99 [-Wmissing-prototypes]

Signed-off-by: Josh Triplett <josh@joshtriplett.org>
---
 mm/page_alloc.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 5b74de6..d857953 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4072,7 +4072,7 @@ int __meminit init_currently_empty_zone(struct zone=
 *zone,
  * was used and there are no special requirements, this is a convenient
  * alternative
  */
-int __meminit __early_pfn_to_nid(unsigned long pfn)
+static int __meminit __early_pfn_to_nid(unsigned long pfn)
 {
 	unsigned long start_pfn, end_pfn;
 	int i, nid;
--=20
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

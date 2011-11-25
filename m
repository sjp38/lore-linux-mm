Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id B03486B0075
	for <linux-mm@kvack.org>; Fri, 25 Nov 2011 00:43:01 -0500 (EST)
Received: by iaek3 with SMTP id k3so5354108iae.14
        for <linux-mm@kvack.org>; Thu, 24 Nov 2011 21:42:58 -0800 (PST)
Message-ID: <4ECF2AD3.5050801@gmail.com>
Date: Fri, 25 Nov 2011 13:42:43 +0800
From: Wang Sheng-Hui <shhuiw@gmail.com>
MIME-Version: 1.0
Subject: Question about mm/compaction.c/acct_isolated: computing nr_anon,
 nr_file
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mel@csn.ul.ie


Why does it double the number in line 233/234?
 
 222/* Update the number of anon and file isolated pages in the zone */
 223static void acct_isolated(struct zone *zone, struct compact_control *cc)
 224{
 225        struct page *page;
 226        unsigned int count[NR_LRU_LISTS] = { 0, };
 227
 228        list_for_each_entry(page, &cc->migratepages, lru) {
 229                int lru = page_lru_base_type(page);
 230                count[lru]++;
 231        }
 232
 233        cc->nr_anon = count[LRU_ACTIVE_ANON] + count[LRU_INACTIVE_ANON];
 234        cc->nr_file = count[LRU_ACTIVE_FILE] + count[LRU_INACTIVE_FILE];
 235        __mod_zone_page_state(zone, NR_ISOLATED_ANON, cc->nr_anon);
 236        __mod_zone_page_state(zone, NR_ISOLATED_FILE, cc->nr_file);
 237}

thanks,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

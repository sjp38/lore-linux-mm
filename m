From: Neil Brown <neilb@cse.unsw.edu.au>
Date: Thu, 29 May 2003 11:08:20 +1000
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <16085.23940.164807.702704@notabene.cse.unsw.edu.au>
Subject: Re: 2.5.70-mm1 bootcrash, possibly RAID-1
In-Reply-To: message from Paul E. Erkkila on Wednesday May 28
References: <20030408042239.053e1d23.akpm@digeo.com>
	<3ED49A14.2020704@aitel.hist.no>
	<20030528111345.GU8978@holomorphy.com>
	<3ED49EB8.1080506@aitel.hist.no>
	<20030528113544.GV8978@holomorphy.com>
	<20030528225913.GA1103@hh.idb.hist.no>
	<3ED54685.5020706@erkkila.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: pee@erkkila.org
Cc: Helge Hafting <helgehaf@aitel.hist.no>, William Lee Irwin III <wli@holomorphy.com>, Andrew Morton <akpm@digeo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Greetings all.

I think this might fix the bug, but I haven't looked very closely
yet.  I will expore it more deeply when I get time.

NeilBrown



 ----------- Diffstat output ------------
 ./drivers/md/raid1.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff ./drivers/md/raid1.c~current~ ./drivers/md/raid1.c
--- ./drivers/md/raid1.c~current~	2003-05-29 11:05:03.000000000 +1000
+++ ./drivers/md/raid1.c	2003-05-29 11:05:08.000000000 +1000
@@ -137,7 +137,7 @@ static void put_all_bios(conf_t *conf, r
 			BUG();
 		bio_put(r1_bio->read_bio);
 		r1_bio->read_bio = NULL;
-	}
+	} else
 	for (i = 0; i < conf->raid_disks; i++) {
 		struct bio **bio = r1_bio->write_bios + i;
 		if (*bio) {
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

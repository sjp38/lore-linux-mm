MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <16087.50544.283105.222031@gargle.gargle.HOWL>
Date: Fri, 30 May 2003 16:56:16 -0400
From: "John Stoffel" <stoffel@lucent.com>
Subject: Re: 2.5.70-mm2
In-Reply-To: <20030530133015.4f305808.akpm@digeo.com>
References: <20030529012914.2c315dad.akpm@digeo.com>
	<20030529042333.3dd62255.akpm@digeo.com>
	<16087.47491.603116.892709@gargle.gargle.HOWL>
	<20030530133015.4f305808.akpm@digeo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>> Any hint on when -mm3 will be out,

Andrew> About ten hours hence, probably.

Great, I'll take a look for it tomorrow morning if I'm lucky.

>> and if it will include the RAID1 patches?

Andrew> I have a raid0 patch from Neil, but no raid1 patch.  I saw one
Andrew> drift past, from Zwane (I think), but wasn't sure that it
Andrew> worked.  If someone has a raid1 fix, please send it.

Hmmm... I could have sworn that Neil sent a RAID1 patch out as well,
which was just adding an 'else' after a block.  Here it is:

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

Andrew> Welll ext3 has been a bit bumpy of course.  It's getting
Andrew> better, but I haven't yet been able to give it a 12-hour bash
Andrew> on the 4-way.  Last time I tried a circuit breaker conked; it
Andrew> lasted three hours but even ext3 needs electricity.  But three
Andrew> hours is very positive - it was hard testing.

I've got a dual PIII 550 with 8 disks on it, so I'll see about beating
on it if I get a change.  I need to take a backup anyway this
weekend... 

Andrew> I'm not testing RAID at present, partly because I'm too
Andrew> stoopid to understand mdadm and partly because the
Andrew> box-with-18-disks heats the room up too much.  This needs to
Andrew> change, because of possible interaction between the IO
Andrew> scheduler work and software RAID.

The mdadm is alot better than the old raid stuff for sure.  

Once I get 2.5.70* up and running, I'll try out my hacks to the
Cyclades driver (and we need a patch for the Kconfig entry as well,
it's wrong in it's description) under ISA to see if I can get it
working.  I'll bounce those to you and Linus if they fly. 

Thanks,
John
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

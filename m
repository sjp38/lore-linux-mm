MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <16086.2429.637069.513978@gargle.gargle.HOWL>
Date: Thu, 29 May 2003 09:22:05 -0400
From: "John Stoffel" <stoffel@lucent.com>
Subject: Re: 2.5.70-mm1 bootcrash, possibly RAID-1
In-Reply-To: <20030528225913.GA1103@hh.idb.hist.no>
References: <20030408042239.053e1d23.akpm@digeo.com>
	<3ED49A14.2020704@aitel.hist.no>
	<20030528111345.GU8978@holomorphy.com>
	<3ED49EB8.1080506@aitel.hist.no>
	<20030528113544.GV8978@holomorphy.com>
	<20030528225913.GA1103@hh.idb.hist.no>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Helge Hafting <helgehaf@aitel.hist.no>
Cc: William Lee Irwin III <wli@holomorphy.com>, Andrew Morton <akpm@digeo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, neilb@cse.unsw.edu.au
List-ID: <linux-mm.kvack.org>

Helge> On Wed, May 28, 2003 at 04:35:44AM -0700, William Lee Irwin III wrote:
>> 
>> Could you log this to serial and get the rest of the oops/BUG? If it's
>> where I think it is, I've been looking at end_page_writeback() and so
>> might have an idea or two.

Helge> I tried 2.5.70-mm1 on the dual celeron at home.  This one has
Helge> scsi instead of ide, so I guess it is a RAID-1 problem.
Helge> This machine has root on raid-1 too.  I believe there where
Helge> several oopses in a row, I captured all of the last one
Helge> thanks to a framebuffer with a small font. Here it is:

I've finally gotten 2.5.70-mm1 compiled and bootable on my system, but
with my /home being RAID1, I was getting crashes that looked alot like
this as well.  This was a Dual PIII Xeon 550, with a mix of IDE and
SCSI drives.  /home was on a pair of 18gb SCSI disks, RAID1.  

I also had problems with the new AIC7xxx driver and had to drop back
to the old one to get a boot.  I think.  Lots and lots of confusion
here.

John
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

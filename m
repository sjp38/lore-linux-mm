Received: from ttb by golbez with local (Exim 3.32 #1 (Debian))
	id 164EA9-0000Ca-00
	for <linux-mm@kvack.org>; Wed, 14 Nov 2001 23:30:05 -0500
Date: Wed, 14 Nov 2001 23:30:05 -0500
Subject: Re: kupdated high load with heavy disk I/O
Message-ID: <20011114233005.A762@tentacle.dhs.org>
References: <35F52ABC3317D511A55300D0B73EB8056FCC19@cinshrexc01.shermfin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <35F52ABC3317D511A55300D0B73EB8056FCC19@cinshrexc01.shermfin.com>
From: John McCutchan <ttb@tentacle.dhs.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

I also have the exact same behaviour when running mkisofs. During the 
creation of the ISO the interactive feel is sluggish and after mkisofs
is complete the box is sluggish and appears to lock up. During
this sluggish period there is alot of disk activity. This is under
2.4.14

John
On Wed, Nov 14, 2001 at 06:01:23PM -0500, Rechenberg, Andrew wrote:
> Hello,
> 
> I have read some previous threads about kupdated consuming 99% of CPU under
> intense disk I/O in kernel 2.4.x on the archives of linux-kernel (April
> 2001), and some issues about I/O problems on linux-mm, but have yet to find
> any suggestions or fixes.  I am currently experiencing the same issue and
> was wondering if anyone has any thoughts or suggestions on the issue.  I am
> not subscribed to the list so would you please CC: me directly on any
> responses?  I can also check out the archives at theaimsgroup.com if a CC:
> would not be appropriate.  Thank you.
> 
> The issue that I am having is that when there is a heavy amount a disk I/O,
> the box becomes slightly unresponsive and kupdated is using 99.9% in 'top.'
> Sometimes the box appears to totally lock up.  If one waits several seconds
> to a couple of minutes the system appears to 'unlock' and runs sluggishly
> for a while.  This cycle will repeat itself until the I/O subsides.  The
> memory usage goes up to the full capacity of the box and then about 10MB of
> swap is used while this problem is occurring.  Memory and swap does not get
> relinquished afer the incident.
> 
> The issue appears in kernel 2.4.14 compiled directly from source from
> kernel.org with no patches.  These problems manifest themselves with only
> one user doing heavy disk I/O.  The normal user load on the box can run
> between 350-450 users so this behavior would be unacceptable because the
> application that is being run is interactive.  With 450 users, and the same
> process running on a 2.2.20 kernel the performance of the box is great, with
> only a very slightly noticeable slow down.
> 
> I am running the Informix database UniVerse version 9.6.2.4 on a 4 processor
> 700MHz Xeon Dell PowerEdge 6400.  The disk subsystem is controlled by a PERC
> 2/DC RAID card with 128MB on-board cache (megaraid driver compiled directly
> in to the kernel).  Data array is on 5 36GB 10K Ultra160 disks in a RAID5
> configuration.  The box has 4GB RAM, but is only using 2GB due to the move
> back to the 2.2 kernel.  The only kernel paramters that have been modified
> are in /proc/sys/kernel/sem.  All filesystems are ext2.
> 
> If you need any more detailed info, please let me know.  Any help on this
> problem would be immensely appreciated.  Thank you in advance.
> 
> Regards,
> Andrew Rechenberg
> Network Team, Sherman Financial Group
> arechenberg@shermanfinancialgroup.com
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/
> 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

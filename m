Date: Thu, 17 Oct 2002 01:01:03 +0530
From: Dipankar Sarma <dipankar@in.ibm.com>
Subject: Re: 2.5.42-mm2 hangs system
Message-ID: <20021017010103.C2380@in.ibm.com>
Reply-To: dipankar@in.ibm.com
References: <20021013160451.GA25494@hswn.dk> <3DA9CA28.155BA5CB@digeo.com> <20021013223332.GA870@hswn.dk> <20021016183907.B29405@in.ibm.com> <20021016154943.GA13695@hswn.dk> <20021016185908.GA863@hswn.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20021016185908.GA863@hswn.dk>; from henrik@hswn.dk on Wed, Oct 16, 2002 at 08:59:08PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: =?iso-8859-1?Q?Henrik_St=F8rner?= <henrik@hswn.dk>
Cc: Maneesh Soni <maneesh@in.ibm.com>, linux-mm@kvack.org, akpm@digeo.com
List-ID: <linux-mm.kvack.org>

On Wed, Oct 16, 2002 at 08:59:08PM +0200, Henrik Storner wrote:
> well you hit the nail right on the head there.
> 
> I've just been running the 2.5.42-mm2 kernel except for the dcache_rcu
> patch for a full hour, and I was unable to reproduce the hangs that I
> saw with the full -mm2 patch installed. Did two full kernel builds
> while reading some mail and doing other stuff - no problems what so
> ever.
> 
> Just to be sure, I re-applied the dcache_rcu patch, rebuilt the
> kernel, booted with the kernel containing dcache_rcu patch,
> and the system died within a few minutes.
> 
> So it is definitely something in the dcache_rcu patch that does it.

Well, I am not quite sure of this yet. Maneesh pointed out this earlier -
In this machine with 2.5.42-mm2 and no dcache_rcu, (with your .config), 
we see  this -

[root@llm04 dbench]# df
Filesystem           1k-blocks      Used Available Use% Mounted on
/dev/sda6              1004024    461168    491852  49% /
/dev/sda1               505605     38348    441153   8% /boot
/dev/sda5              2514172   1791560    594900  76% /usr
none                    257532         0    257532   0% /dev/shm
/dev/sdb5              6324896     23996   5979604   1% /mnt/sdb5
llm04:/mnt/sdb5        6324896     23968   5979616   1% /mnt/sdc1
/dev/sda2              9068648   3993040   4614948  47% /home
[root@llm04 dbench]# pwd
/mnt/sdc1/dbench
root@llm04 dbench]# ./dbench 4
4 clients started
..........................................................................................................................................rmdir CLIENTS/CLIENT2/~DMTMP/WORDPRO failed (Directory not empty)
rmdir CLIENTS/CLIENT2/~DMTMP/PARADOX failed (Directory not empty)
rmdir CLIENTS/CLIENT2/~DMTMP failed (Directory not empty)
+.......rmdir CLIENTS/CLIENT0/~DMTMP/WORDPRO failed (Directory not empty)
rmdir CLIENTS/CLIENT0/~DMTMP/PARADOX failed (Directory not empty)
.rmdir CLIENTS/CLIENT0/~DMTMP failed (Directory not empty)
+.rmdir CLIENTS/CLIENT3/~DMTMP/WORDPRO failed (Directory not empty)
rmdir CLIENTS/CLIENT3/~DMTMP/PARADOX failed (Directory not empty)
rmdir CLIENTS/CLIENT3/~DMTMP failed (Directory not empty)
+.rmdir CLIENTS/CLIENT1/~DMTMP/WORDPRO failed (Directory not empty)
rmdir CLIENTS/CLIENT1/~DMTMP/PARADOX failed (Directory not empty)
rmdir CLIENTS/CLIENT1/~DMTMP failed (Directory not empty)
+****
Throughput 36.6733 MB/sec (NB=45.8417 MB/sec  366.733 MBit/sec)

This needs more investigation. I would be really supprised if dcache_rcu
has any effect on UP code.

Thanks
-- 
Dipankar Sarma  <dipankar@in.ibm.com> http://lse.sourceforge.net
Linux Technology Center, IBM Software Lab, Bangalore, India.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

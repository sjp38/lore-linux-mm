Date: Wed, 02 Jul 2003 11:12:00 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: 2.5.73-mm3
Message-ID: <530600000.1057169520@flay>
In-Reply-To: <20030701221829.3e0edf3a.akpm@digeo.com>
References: <20030701203830.19ba9328.akpm@digeo.com><15570000.1057122469@[10.10.2.4]> <20030701221829.3e0edf3a.akpm@digeo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>> VFS: Cannot open root device "sda2" or unknown-block(0,0)
>> Please append a correct "root=" boot option
>> Kernel panic: VFS: Unable to mount root fs on unknown-block(0,0)
>> 
>> mm2 works fine.
>> 
>> Seems like no SCSI drivers at all got loaded ... same config file,
>> feral on ISP.
> 
> Works OK here.
> 
> The config option for the feral driver got gratuitously renamed.  To
> CONFIG_SCSI_FERAL_ISP.

Bah humbug.

Well, I tried that now. Still E_NO_WORKEE though. Does spit out one
error:

scsi HBA driver Qlogic ISP 10X0/2X00 didn't set a release method.
st: Version 20030622, fixed bufsize 32768, s/g segs 256
oprofile: using NMI interrupt.
NET4: Linux TCP/IP 1.0 for NET4.0
IP: routing cache hash table of 131072 buckets, 1024Kbytes
TCP: Hash tables configured (established 524288 bind 65536)
NET4: Unix domain sockets 1.0/SMP for Linux NET4.0.
VFS: Cannot open root device "sda2" or unknown-block(0,0)
Please append a correct "root=" boot option
Kernel panic: VFS: Unable to mount root fs on unknown-block(0,0)

Note the "scsi HBA driver Qlogic ISP 10X0/2X00 didn't set a release method"
bit.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

Date: Tue, 1 Jul 2003 22:18:29 -0700
From: Andrew Morton <akpm@digeo.com>
Subject: Re: 2.5.73-mm3
Message-Id: <20030701221829.3e0edf3a.akpm@digeo.com>
In-Reply-To: <15570000.1057122469@[10.10.2.4]>
References: <20030701203830.19ba9328.akpm@digeo.com>
	<15570000.1057122469@[10.10.2.4]>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"Martin J. Bligh" <mbligh@aracnet.com> wrote:
>
> 
> 
> --Andrew Morton <akpm@digeo.com> wrote (on Tuesday, July 01, 2003 20:38:30 -0700):
> 
> > ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.5/2.5.73/2.5.73-mm3/
> 
> ;-(
> 
> VFS: Cannot open root device "sda2" or unknown-block(0,0)
> Please append a correct "root=" boot option
> Kernel panic: VFS: Unable to mount root fs on unknown-block(0,0)
> 
> mm2 works fine.
> 
> Seems like no SCSI drivers at all got loaded ... same config file,
> feral on ISP.

Works OK here.

The config option for the feral driver got gratuitously renamed.  To
CONFIG_SCSI_FERAL_ISP.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

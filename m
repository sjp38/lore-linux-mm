Date: Tue, 01 Jul 2003 22:07:51 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: 2.5.73-mm3
Message-ID: <15570000.1057122469@[10.10.2.4]>
In-Reply-To: <20030701203830.19ba9328.akpm@digeo.com>
References: <20030701203830.19ba9328.akpm@digeo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


--Andrew Morton <akpm@digeo.com> wrote (on Tuesday, July 01, 2003 20:38:30 -0700):

> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.5/2.5.73/2.5.73-mm3/

;-(

VFS: Cannot open root device "sda2" or unknown-block(0,0)
Please append a correct "root=" boot option
Kernel panic: VFS: Unable to mount root fs on unknown-block(0,0)

mm2 works fine.

Seems like no SCSI drivers at all got loaded ... same config file,
feral on ISP.

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

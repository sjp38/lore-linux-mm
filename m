From: Alistair J Strachan <alistair@devzero.co.uk>
Subject: Re: 2.6.0-test5-mm4
Date: Mon, 22 Sep 2003 14:49:37 +0100
References: <20030922013548.6e5a5dcf.akpm@osdl.org> <200309221317.42273.alistair@devzero.co.uk> <20030922143605.GA9961@gemtek.lt>
In-Reply-To: <20030922143605.GA9961@gemtek.lt>
MIME-Version: 1.0
Content-Disposition: inline
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200309221449.37677.alistair@devzero.co.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Zilvinas Valinskas <zilvinas@gemtek.lt>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Monday 22 September 2003 15:36, Zilvinas Valinskas wrote:
[snip]
> >
> > VFS: Cannot open root device "302" or hda2.
> > Please append correct "root=" boot option.
> > Kernel Panic: VFS: Unable to mount root fs on hda2.
>
> Do you use devfsd ?
>

No. As I said, I mount /dev with mount -t devfs devfs /dev in a sysinit 
bootscript. Whether it's in the kernel or not shouldn't make any difference. 
Maybe I just need to reissue LILO after booting the 32bit dev_t kernel?

> I had to specify root like this :
> root=/dev/ide/host0/bus0/target0/lun0/part5  then it worked just fine.
>

I'll try that, thanks. But I have this in lilo.conf:

boot=/dev/discs/disc0/disc
root=/dev/discs/disc0/part2

/dev/discs is indeed a symlink, but it should be resolved when LILO is 
installed, i.e., prior to the reboot. Why has this behaviour changed?

Cheers,
Alistair.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

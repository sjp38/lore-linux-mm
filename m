Subject: Re: Unable to boot 2.6.0-test1-mm2 (mm1 is OK) on RH 9.0.93
	(Severn)
From: Steven Cole <elenstev@mesatop.com>
In-Reply-To: <20030722180125.54503.qmail@web12303.mail.yahoo.com>
References: <20030722180125.54503.qmail@web12303.mail.yahoo.com>
Content-Type: text/plain
Message-Id: <1058898314.1675.26.camel@spc9.esa.lanl.gov>
Mime-Version: 1.0
Date: 22 Jul 2003 12:25:15 -0600
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ravi Krishnamurthy <kravi26@yahoo.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2003-07-22 at 12:01, Ravi Krishnamurthy wrote:
> --- Steven Cole <elenstev@mesatop.com> wrote:
> > I get this error when trying to boot 2.6.0-test1-mm2
> > using the new Red
> > Hat beta (Severn).  2.6.0-test2-mm2 runs successfully on
> > a couple of
> > other test boxes of mine.
> > 
> > VFS: Cannot open root device "hda1" or unknown-block(0,0)
> > Please append a correct "root=" boot option
> > Kernel panic: VFS: Unable to mount root fs on
> > unknown-block(0,0)
> 
>  The last time I had this problem, I found that
> CONFIG_IDEDISK_MULTI_MODE was off and my disk wouldn't
> get recognized without that. But you say your other
> kernels are working, so I am not sure this is the problem.
> 
> -Ravi.

Thanks, but in this case, that's not it.

[steven@spc1 linux-2.6.0-test1-mm2]$ grep ^CONFIG_IDE .config
CONFIG_IDE=y
CONFIG_IDEDISK_MULTI_MODE=y
CONFIG_IDEPCI_SHARE_IRQ=y
CONFIG_IDEDMA_PCI_AUTO=y
CONFIG_IDEDMA_AUTO=y

I may try to build the kernel with another compiler. Severn has this
fairly new gcc:
[steven@spc1 etc]$ gcc --version
gcc (GCC) 3.3 20030715 (Red Hat Linux 3.3-14)

Steven


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

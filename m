Subject: Re: 2.5.70-mm9
From: James Bottomley <James.Bottomley@steeleye.com>
In-Reply-To: <20030618003838.06144cf9.akpm@digeo.com>
References: <20030613013337.1a6789d9.akpm@digeo.com>
	<3EEAD41B.2090709@us.ibm.com> <20030614010139.2f0f1348.akpm@digeo.com>
	<1055637690.1396.15.camel@w-ming2.beaverton.ibm.com>
	<20030614232049.6610120d.akpm@digeo.com>
	<1055920382.1374.11.camel@w-ming2.beaverton.ibm.com>
	<20030618003838.06144cf9.akpm@digeo.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 18 Jun 2003 08:54:44 -0500
Message-Id: <1055944486.2075.9.camel@mulgrave>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: Mingming Cao <cmm@us.ibm.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2003-06-18 at 02:38, Andrew Morton wrote:
> Mingming Cao <cmm@us.ibm.com> wrote:
> >
> > I re-run the many fsx tests with feral driver on 2.5.70mm9, ext3
> >  fileystems, on deadline scheduler and as scheduler respectively.  Both
> >  tests passed.  They were running for more than 24 hours without any
> >  problems. So it could be a bug in the device driver that I used
> >  before(QLA2xxx V8).  Before the fsx tests failed on ext3 on either
> >  deadline scheduler or as scheduler.
> 
> Well it could be a bug in the driver, or it could be a bug in the generic
> block/iosched area which was just triggered by the particular way in which
> that driver exercises the core code.
> 
> James, do we have the latest-and-greatest version of the qlogic driver
> in-tree?  ISTR that there's an update out there somewhere?

I'm still currently keeping the qlogic and feral drivers out of tree. 
Feral because Matthew Jacob thinks its not ready yet and Qlogic because
I was waiting for the must-fix list (I'll prod hch again for this).

You can get the current qlogic driver at

  http://sourceforge.net/projects/linux-qla2xxx/

And I will update the BK tree at linux-scsi.bkbits.net

James


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

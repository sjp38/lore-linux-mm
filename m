Date: Wed, 2 Jul 2003 08:18:42 -0700
From: Andrew Morton <akpm@digeo.com>
Subject: Re: 2.5.73-mm3
Message-Id: <20030702081842.45f4056f.akpm@digeo.com>
In-Reply-To: <20030702105458.GH1267@in.ibm.com>
References: <20030701203830.19ba9328.akpm@digeo.com>
	<20030702105458.GH1267@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: maneesh@in.ibm.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Maneesh Soni <maneesh@in.ibm.com> wrote:
>
> On Wed, Jul 02, 2003 at 03:39:54AM +0000, Andrew Morton wrote:
> > ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.5/2.5.73/2.5.73-mm3/
> > 
> > . The ext2 "free inodes corrupted" problem which Martin saw should be
> >   fixed.
> > 
> > . The ext3 assertion failure which Maneesh hit should be fixed (I can't
> >   reproduce this, please retest?)
> > 
> 
> It is fixed. Ran multiple iterations without any ext3 assertion failure. 

Sweet, thanks.

And thanks also for the ext3-debug trace - that found the bug in sixty
seconds of peering.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

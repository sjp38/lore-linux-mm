Date: Tue, 5 Feb 2008 10:40:28 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [2.6.24 REGRESSION] BUG: Soft lockup - with VFS
Message-Id: <20080205104028.190192b1.akpm@linux-foundation.org>
In-Reply-To: <1202219216.27371.24.camel@moss-spartans.epoch.ncsc.mil>
References: <6101e8c40801280031v1a860e90gfb3992ae5db37047@mail.gmail.com>
	<20080204213911.1bcbaf66.akpm@linux-foundation.org>
	<1202219216.27371.24.camel@moss-spartans.epoch.ncsc.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Stephen Smalley <sds@tycho.nsa.gov>
Cc: "\"Oliver =?ISO-8859-1?B?UGludGVyIiAoUGludOlyIE9saXbpciki?= <oliver.pntr@gmail.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, James Morris <jmorris@namei.org>"@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Tue, 05 Feb 2008 08:46:56 -0500 Stephen Smalley <sds@tycho.nsa.gov> wrote:

> 
> On Mon, 2008-02-04 at 21:39 -0800, Andrew Morton wrote:
> > On Mon, 28 Jan 2008 09:31:43 +0100 "Oliver Pinter (Pinter Oliver)"  <oliver.pntr@gmail.com> wrote:
> > 
> > > hi all!
> > > 
> > > in the 2.6.24 become i some soft lockups with usb-phone, when i pluged
> > > in the mobile, then the vfs-layer crashed. am afternoon can i the
> > > .config send, and i bisected the kernel, when i have time.
> > > 
> > > pictures from crash:
> > > http://students.zipernowsky.hu/~oliverp/kernel/regression_2624/
> > 
> > It looks like selinux's file_has_perm() is doing spin_lock() on an
> > uninitialised (or already locked) spinlock.
> 
> The trace looks bogus to me - I don't see how file_has_perm() could have
> been called there, and file_has_perm() doesn't directly take any spin
> locks.
> 

Oliver, could you please set CONFIG_FRAME_POINTER=y (which might get a
better trace), and perhaps try Linus's latest tree from
ftp://ftp.kernel.org/pub/linux/kernel/v2.6/snapshots/ (which is a bit more
careful about telling us about possibly-bogus backtrace entries)?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

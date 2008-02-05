Subject: Re: [2.6.24 REGRESSION] BUG: Soft lockup - with VFS
From: Stephen Smalley <sds@tycho.nsa.gov>
In-Reply-To: <20080204213911.1bcbaf66.akpm@linux-foundation.org>
References: <6101e8c40801280031v1a860e90gfb3992ae5db37047@mail.gmail.com>
	 <20080204213911.1bcbaf66.akpm@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Date: Tue, 05 Feb 2008 08:46:56 -0500
Message-Id: <1202219216.27371.24.camel@moss-spartans.epoch.ncsc.mil>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "\"Oliver Pinter =?ISO-8859-1?Q?=28Pint=E9r_Oliv=E9r=29=22?=" <oliver.pntr@gmail.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, James Morris <jmorris@namei.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2008-02-04 at 21:39 -0800, Andrew Morton wrote:
> On Mon, 28 Jan 2008 09:31:43 +0100 "Oliver Pinter (PintA(C)r OlivA(C)r)"  <oliver.pntr@gmail.com> wrote:
> 
> > hi all!
> > 
> > in the 2.6.24 become i some soft lockups with usb-phone, when i pluged
> > in the mobile, then the vfs-layer crashed. am afternoon can i the
> > .config send, and i bisected the kernel, when i have time.
> > 
> > pictures from crash:
> > http://students.zipernowsky.hu/~oliverp/kernel/regression_2624/
> 
> It looks like selinux's file_has_perm() is doing spin_lock() on an
> uninitialised (or already locked) spinlock.

The trace looks bogus to me - I don't see how file_has_perm() could have
been called there, and file_has_perm() doesn't directly take any spin
locks.

-- 
Stephen Smalley
National Security Agency

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

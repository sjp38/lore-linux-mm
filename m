Date: Tue, 5 Feb 2008 21:02:36 +1100 (EST)
From: James Morris <jmorris@namei.org>
Subject: Re: [2.6.24 REGRESSION] BUG: Soft lockup - with VFS
In-Reply-To: <20080204213911.1bcbaf66.akpm@linux-foundation.org>
Message-ID: <Xine.LNX.4.64.0802052100510.2122@us.intercode.com.au>
References: <6101e8c40801280031v1a860e90gfb3992ae5db37047@mail.gmail.com>
 <20080204213911.1bcbaf66.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="927316971-996416682-1202205756=:2122"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: =?ISO-8859-1?Q?Oliver_Pinter_=28Pint=E9r_Oliv=E9r=29?= <oliver.pntr@gmail.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Stephen Smalley <sds@tycho.nsa.gov>, Eric Paris <eparis@redhat.com>
List-ID: <linux-mm.kvack.org>

--927316971-996416682-1202205756=:2122
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Mon, 4 Feb 2008, Andrew Morton wrote:

> On Mon, 28 Jan 2008 09:31:43 +0100 "Oliver Pinter (Pinter Oliver)"  <oliver.pntr@gmail.com> wrote:
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

Perplexing.

Do you have all of the lock debugging enabled?


- James
-- 
James Morris
<jmorris@namei.org>
--927316971-996416682-1202205756=:2122--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

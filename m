Date: Mon, 4 Feb 2008 21:39:11 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [2.6.24 REGRESSION] BUG: Soft lockup - with VFS
Message-Id: <20080204213911.1bcbaf66.akpm@linux-foundation.org>
In-Reply-To: <6101e8c40801280031v1a860e90gfb3992ae5db37047@mail.gmail.com>
References: <6101e8c40801280031v1a860e90gfb3992ae5db37047@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: =?ISO-8859-1?B?Ik9saXZlciBQaW50ZXIgKFBpbnTpciBPbGl26XIpIg==?= <oliver.pntr@gmail.com>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Stephen Smalley <sds@tycho.nsa.gov>, James Morris <jmorris@namei.org>
List-ID: <linux-mm.kvack.org>

On Mon, 28 Jan 2008 09:31:43 +0100 "Oliver Pinter (Pinter Oliver)"  <oliver.pntr@gmail.com> wrote:

> hi all!
> 
> in the 2.6.24 become i some soft lockups with usb-phone, when i pluged
> in the mobile, then the vfs-layer crashed. am afternoon can i the
> .config send, and i bisected the kernel, when i have time.
> 
> pictures from crash:
> http://students.zipernowsky.hu/~oliverp/kernel/regression_2624/

It looks like selinux's file_has_perm() is doing spin_lock() on an
uninitialised (or already locked) spinlock.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Tue, 5 Feb 2008 14:19:44 -0800
From: Pete Zaitcev <zaitcev@redhat.com>
Subject: Re: [2.6.24 REGRESSION] BUG: Soft lockup - with VFS
Message-Id: <20080205141944.773140a1.zaitcev@redhat.com>
In-Reply-To: <20080205140506.c6354490.akpm@linux-foundation.org>
References: <6101e8c40801280031v1a860e90gfb3992ae5db37047@mail.gmail.com>
	<20080204213911.1bcbaf66.akpm@linux-foundation.org>
	<1202219216.27371.24.camel@moss-spartans.epoch.ncsc.mil>
	<20080205104028.190192b1.akpm@linux-foundation.org>
	<6101e8c40802051115v12d3c02br24873ef1014dbea9@mail.gmail.com>
	<6101e8c40802051321l13268239m913fd90f56891054@mail.gmail.com>
	<6101e8c40802051348w2250e593x54f777bb771bd903@mail.gmail.com>
	<20080205140506.c6354490.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Oliver Pinter <oliver.pntr@gmail.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, James Morris <jmorris@namei.org>, linux-usb@vger.kernel.org, zaitcev@redhat.com
List-ID: <linux-mm.kvack.org>

On Tue, 5 Feb 2008 14:05:06 -0800, Andrew Morton <akpm@linux-foundation.org> wrote:

> Looks like you deadlocked in ub_request_fn().  I assume that you were using
> ub.c in 2.6.23 and that it worked OK?  If so, we broke it, possibly via
> changes to the core block layer.
> 
> I think ub.c is basically abandoned in favour of usb-storage.  If so,
> perhaps we should remove or disble ub.c?

Actually I think it may be an argument for keeping ub, if ub exposes
a bug in the __blk_end_request. I'll look at the head of the thread
and see if Mr. Pinter has hit anything related to Mr. Ueda's work.

-- Pete

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

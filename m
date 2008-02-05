Received: by ug-out-1314.google.com with SMTP id u40so283975ugc.29
        for <linux-mm@kvack.org>; Tue, 05 Feb 2008 14:35:40 -0800 (PST)
Message-ID: <6101e8c40802051435ibcbc83et4d07875c447b970b@mail.gmail.com>
Date: Tue, 5 Feb 2008 23:35:40 +0100
From: "Oliver Pinter" <oliver.pntr@gmail.com>
Subject: Re: [2.6.24 REGRESSION] BUG: Soft lockup - with VFS
In-Reply-To: <6101e8c40802051429r2942f8a7g5aa28b147603b669@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <6101e8c40801280031v1a860e90gfb3992ae5db37047@mail.gmail.com>
	 <20080204213911.1bcbaf66.akpm@linux-foundation.org>
	 <1202219216.27371.24.camel@moss-spartans.epoch.ncsc.mil>
	 <20080205104028.190192b1.akpm@linux-foundation.org>
	 <6101e8c40802051115v12d3c02br24873ef1014dbea9@mail.gmail.com>
	 <6101e8c40802051321l13268239m913fd90f56891054@mail.gmail.com>
	 <6101e8c40802051348w2250e593x54f777bb771bd903@mail.gmail.com>
	 <20080205140506.c6354490.akpm@linux-foundation.org>
	 <20080205141944.773140a1.zaitcev@redhat.com>
	 <6101e8c40802051429r2942f8a7g5aa28b147603b669@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pete Zaitcev <zaitcev@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, James Morris <jmorris@namei.org>, linux-usb@vger.kernel.org
List-ID: <linux-mm.kvack.org>

declaration of function 'end_that_request_first'
/usr/data/source/git/linux-2.6/drivers/block/ub.c:820: error: implicit
declaration of function 'end_that_request_last'
make[7]: *** [drivers/block/ub.o] Error 1
make[6]: *** [drivers/block] Error 2
make[5]: *** [drivers] Error 2
make[5]: *** Waiting for unfinished jobs....


On 2/5/08, Oliver Pinter <oliver.pntr@gmail.com> wrote:
> i reverted this commit 7d699bafe258ebd8f9b4ec182c554200b369a504 , and
> now compile ...
>
> On 2/5/08, Pete Zaitcev <zaitcev@redhat.com> wrote:
> > On Tue, 5 Feb 2008 14:05:06 -0800, Andrew Morton
> <akpm@linux-foundation.org>
> > wrote:
> >
> > > Looks like you deadlocked in ub_request_fn().  I assume that you were
> > using
> > > ub.c in 2.6.23 and that it worked OK?  If so, we broke it, possibly via
> > > changes to the core block layer.
> > >
> > > I think ub.c is basically abandoned in favour of usb-storage.  If so,
> > > perhaps we should remove or disble ub.c?
> >
> > Actually I think it may be an argument for keeping ub, if ub exposes
> > a bug in the __blk_end_request. I'll look at the head of the thread
> > and see if Mr. Pinter has hit anything related to Mr. Ueda's work.
> >
> > -- Pete
> >
>
>
> --
> Thanks,
> Oliver
>


-- 
Thanks,
Oliver

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

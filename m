From: "Oliver Pinter" <oliver.pntr@gmail.com>
Subject: Re: [2.6.24 REGRESSION] BUG: Soft lockup - with VFS
Date: Tue, 5 Feb 2008 22:48:29 +0100
Message-ID: <6101e8c40802051348w2250e593x54f777bb771bd903@mail.gmail.com>
References: <6101e8c40801280031v1a860e90gfb3992ae5db37047@mail.gmail.com>
	 <20080204213911.1bcbaf66.akpm@linux-foundation.org>
	 <1202219216.27371.24.camel@moss-spartans.epoch.ncsc.mil>
	 <20080205104028.190192b1.akpm@linux-foundation.org>
	 <6101e8c40802051115v12d3c02br24873ef1014dbea9@mail.gmail.com>
	 <6101e8c40802051321l13268239m913fd90f56891054@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <6101e8c40802051321l13268239m913fd90f56891054@mail.gmail.com>
Content-Disposition: inline
Sender: linux-fsdevel-owner@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, "=?ISO-8859-1?Q?Oliver_Pinter_(Pint=E9r_Oliv=E9r)\"?=" <oliver.pntr@gmail.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, James Morris <jmorris@namei.org>
List-Id: linux-mm.kvack.org

On 2/5/08, Oliver Pinter <oliver.pntr@gmail.com> wrote:
> http://students.zipernowsky.hu/~oliverp/kernel/regression_2624/
>
> uploaded:
> kernel image
> .config
> new pictures
> lspci
> lsusb
>
> -----
>
> when read for /dev/uba then crashed the kernel, the read is egal, the=
t
> dd or mount is ...
>
> On 2/5/08, Oliver Pinter <oliver.pntr@gmail.com> wrote:
> > yes, but auch too with latest git ... my top is on:
> > 9ef9dc69d4167276c04590d67ee55de8380bc1ad
> >
> > then i complie the new kernel
> >
> > On 2/5/08, Andrew Morton <akpm@linux-foundation.org> wrote:
> > > On Tue, 05 Feb 2008 08:46:56 -0500 Stephen Smalley <sds@tycho.nsa=
=2Egov>
> > > wrote:
> > >
> > > >
> > > > On Mon, 2008-02-04 at 21:39 -0800, Andrew Morton wrote:
> > > > > On Mon, 28 Jan 2008 09:31:43 +0100 "Oliver Pinter (Pint=E9r O=
liv=E9r)"
> > > <oliver.pntr@gmail.com> wrote:
> > > > >
> > > > > > hi all!
> > > > > >
> > > > > > in the 2.6.24 become i some soft lockups with usb-phone, wh=
en i
> > pluged
> > > > > > in the mobile, then the vfs-layer crashed. am afternoon can=
 i the
> > > > > > .config send, and i bisected the kernel, when i have time.
> > > > > >
> > > > > > pictures from crash:
> > > > > > http://students.zipernowsky.hu/~oliverp/kernel/regression_2=
624/
> > > > >
> > > > > It looks like selinux's file_has_perm() is doing spin_lock() =
on an
> > > > > uninitialised (or already locked) spinlock.
> > > >
> > > > The trace looks bogus to me - I don't see how file_has_perm() c=
ould
> > have
> > > > been called there, and file_has_perm() doesn't directly take an=
y spin
> > > > locks.
> > > >
> > >
> > > Oliver, could you please set CONFIG_FRAME_POINTER=3Dy (which migh=
t get a
> > > better trace), and perhaps try Linus's latest tree from
> > > ftp://ftp.kernel.org/pub/linux/kernel/v2.6/snapshots/ (which is a=
 bit
> > more
> > > careful about telling us about possibly-bogus backtrace entries)?
> > >
> > > Thanks.
> > >
> >
> >
> > --
> > Thanks,
> > Oliver
> >
>
>
> --
> Thanks,
> Oliver
>


--=20
Thanks,
Oliver
-
To unsubscribe from this list: send the line "unsubscribe linux-fsdevel=
" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

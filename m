Return-Path: <linux-kernel-owner@vger.kernel.org>
Date: Wed, 2 May 2018 15:11:13 +0000
From: "Luis R. Rodriguez" <mcgrof@kernel.org>
Subject: Re: [PATCH] mm: provide a fallback for PAGE_KERNEL_RO for
 architectures
Message-ID: <20180502151113.GB27853@wotan.suse.de>
References: <20180428001526.22475-1-mcgrof@kernel.org>
 <CAMuHMdUpc6=j62E7Xrcid6tKU5FRUZsiSVK7J=KD09epQ=9xfA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAMuHMdUpc6=j62E7Xrcid6tKU5FRUZsiSVK7J=KD09epQ=9xfA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: "Luis R. Rodriguez" <mcgrof@kernel.org>, Arnd Bergmann <arnd@arndb.de>, Matthew Wilcox <mawilcox@microsoft.com>, Greg KH <gregkh@linuxfoundation.org>, Linux-Arch <linux-arch@vger.kernel.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>
List-ID: <linux-mm.kvack.org>

On Wed, May 02, 2018 at 12:08:57PM +0200, Geert Uytterhoeven wrote:
> Hi Luis,
> 
> On Sat, Apr 28, 2018 at 2:15 AM, Luis R. Rodriguez <mcgrof@kernel.org> wrote:
> > Some architectures do not define PAGE_KERNEL_RO, best we can do
> > for them is to provide a fallback onto PAGE_KERNEL. Remove the
> > hack from the firmware loader and move it onto the asm-generic
> > header, and document while at it the affected architectures
> > which do not have a PAGE_KERNEL_RO:
> >
> >   o alpha
> >   o ia64
> >   o m68k
> >   o mips
> >   o sparc64
> >   o sparc
> >
> > Blessed-by: 0-day
> > Signed-off-by: Luis R. Rodriguez <mcgrof@kernel.org>
> 
> I believe the "best we can do" is to add the missing definitions for the
> architectures where the hardware does support it?

True, but we cannot wait for every architecture to implement a feature to then
such generics upstream, specially when we have common places which use that.
Matthew did send a patch to add ia64 support for PAGE_KERNEL_RO, so I'll
respin the patch to add that and also move the other define he suggested.

At least we'd now have a list of documented archs which need further work too.

  Luis

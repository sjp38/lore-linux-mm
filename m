Date: Tue, 10 Feb 2004 03:25:10 +0100
From: Karsten Keil <kkeil@suse.de>
Subject: Re: 2.6.3-rc1-mm1
Message-ID: <20040210022510.GA17364@pingi3.kke.suse.de>
References: <20040209014035.251b26d1.akpm@osdl.org> <1076320225.671.7.camel@chevrolet.hybel> <20040209022453.44e7f453.akpm@osdl.org> <20040209115618.GA7639@pingi3.kke.suse.de> <20040209112207.4e7d97c9.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040209112207.4e7d97c9.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: liste@jordet.nu, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linus@osdl.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 09, 2004 at 11:22:07AM -0800, Andrew Morton wrote:
> Karsten Keil <kkeil@suse.de> wrote:
> >
> > I have also BitKeeper running here with a clone of the linux-2.5
> > tree,
> 
> Is this the master tree, or is this a copy of what is in i4l CVS?

It is a bk clone http://linux.bkbits.net:8080/linux-2.5

And I  imported the i4l-2.6.3-rc1-bk2 patch

> 
> Either way, let's find a way in which I can obtain the latest version and
> also be kept up to date with any fixes.  Thanks.

Here are the latest versions, since they are so big only as reference:
Linus tree:
ftp://ftp.isdn4linux.de/pub/isdn4linux/kernel/v2.6/i4l-2.6.3-rc1-bk2.gz

Andrew tree:
ftp://ftp.isdn4linux.de/pub/isdn4linux/kernel/v2.6/i4l-2.6.3-rc1-mm1.gz

The result of both patches are the same source, but in Andrews tree
some smaller fixes were already included, to avoid rejects I
created patches for both trees.

ChangeLog:

- new port of 2.4 I4L core to 2.6
- new port of 2.4 I$L HiSax to 2.6
- fixes for I4L CAPI subsystem to make it stable in 2.6
- fix parameter handling of AVM ISA cards (calle)
- cleanup ISDN config variables

These patches are in sync with I4L cvs (kernel 2.6 branch).

-- 
Karsten Keil
SuSE Labs
ISDN development
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

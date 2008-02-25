Date: Mon, 25 Feb 2008 21:38:53 +0100
From: =?utf-8?B?SsO2cm4=?= Engel <joern@logfs.org>
Subject: Re: Page scan keeps touching kernel text pages
Message-ID: <20080225203852.GA15904@lazybastard.org>
References: <20080224144710.GD31293@lazybastard.org> <20080225185319.GA14699@lazybastard.org> <20080225192127.GA20322@shadowen.org> <200802251346.32289.dave.mccracken@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <200802251346.32289.dave.mccracken@oracle.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dave.mccracken@oracle.com>
Cc: Andy Whitcroft <apw@shadowen.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 25 February 2008 13:46:32 -0600, Dave McCracken wrote:
> On Monday 25 February 2008, Andy Whitcroft wrote:
> > I thought that init sections were deliberatly pushed to the end of the
> > kernel when linked, cirtainly on my laptop here that seems to be so.
> > That would make the first two "after" the kernel. A The other two appear
> > to be before the traditional kernel load address, which is 0x100000, so
> > those pages are before not in the kernel?
> 
> I believe the memory below the kernel load address on x86 is returned to the 
> free memory pool at some point during boot, which would explain those 
> addresses.

It does explain all pages.  Sorry about the noise from an mm-newbie.

JA?rn

-- 
Joern's library part 14:
http://www.sandpile.org/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

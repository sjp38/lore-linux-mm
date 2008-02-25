From: Dave McCracken <dave.mccracken@oracle.com>
Subject: Re: Page scan keeps touching kernel text pages
Date: Mon, 25 Feb 2008 13:46:32 -0600
References: <20080224144710.GD31293@lazybastard.org> <20080225185319.GA14699@lazybastard.org> <20080225192127.GA20322@shadowen.org>
In-Reply-To: <20080225192127.GA20322@shadowen.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
Message-Id: <200802251346.32289.dave.mccracken@oracle.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Monday 25 February 2008, Andy Whitcroft wrote:
> I thought that init sections were deliberatly pushed to the end of the
> kernel when linked, cirtainly on my laptop here that seems to be so.
> That would make the first two "after" the kernel.  The other two appear
> to be before the traditional kernel load address, which is 0x100000, so
> those pages are before not in the kernel?

I believe the memory below the kernel load address on x86 is returned to the 
free memory pool at some point during boot, which would explain those 
addresses.

Dave McCracken

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Fri, 14 Oct 2005 14:14:55 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: [Patch 2/2] Special Memory (mspec) driver.
Message-ID: <20051014191455.GA14418@lnx-holt.americas.sgi.com>
References: <20051012194022.GE17458@lnx-holt.americas.sgi.com> <20051012194233.GG17458@lnx-holt.americas.sgi.com> <20051012202925.GA23081@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20051012202925.GA23081@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jack Steiner <steiner@sgi.com>
Cc: Robin Holt <holt@sgi.com>, linux-ia64@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, hch@infradead.org, jgarzik@pobox.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On Wed, Oct 12, 2005 at 03:29:25PM -0500, Jack Steiner wrote:
> On Wed, Oct 12, 2005 at 02:42:33PM -0500, Robin Holt wrote:
> > Introduce the special memory (mspec) driver.  This is used to allow
> > userland to map fetchop, etc pages
> > 
> > Signed-off-by: holt@sgi.com
> 
> Robin - 
> 
> I think you are missing the shub2 code that is required for flushing the fetchop 
> cache. The cache is new in shub2. Take a look at the old PP4 driver - clear_mspec_page();

Done.  Will test when I get access to a shub2 machine.

Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

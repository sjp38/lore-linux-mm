Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id A2ADD6B008C
	for <linux-mm@kvack.org>; Wed, 28 Nov 2012 20:34:44 -0500 (EST)
Date: Thu, 29 Nov 2012 10:34:41 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 3/3] zram: get rid of lockdep warning
Message-ID: <20121129013441.GB24077@blaptop>
References: <1354070146-18619-1-git-send-email-minchan@kernel.org>
 <1354070146-18619-3-git-send-email-minchan@kernel.org>
 <50B625B5.2070601@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50B625B5.2070601@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Marchand <jmarchan@redhat.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Pekka Enberg <penberg@cs.helsinki.fi>

On Wed, Nov 28, 2012 at 03:54:45PM +0100, Jerome Marchand wrote:
> On 11/28/2012 03:35 AM, Minchan Kim wrote:
> > Lockdep complains about recursive deadlock of zram->init_lock.
> > [1] made it false positive because we can't request IO to zram
> > before setting disksize. Anyway, we should shut lockdep up to
> > avoid many reporting from user.
> > 
> > This patch allocates zram's metadata out of lock so we can fix it.
> 
> Is that me or the functions zram_meta_alloc/free are missing?

Who bite my zram_meta_alloc/free? :)
Will resend with your suggestion for removing GFP_ATOMIC.

Thanks!

> 
> Regards,
> Jerome
-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

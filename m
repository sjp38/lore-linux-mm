Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 93F3A6B0032
	for <linux-mm@kvack.org>; Mon, 12 Aug 2013 08:19:28 -0400 (EDT)
Date: Mon, 12 Aug 2013 08:19:08 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH v2 0/4] zcache: a compressed file page cache
Message-ID: <20130812121908.GA3196@phenom.dumpdata.com>
References: <1375788977-12105-1-git-send-email-bob.liu@oracle.com>
 <20130806135800.GC1048@kroah.com>
 <52010714.2090707@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52010714.2090707@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <bob.liu@oracle.com>
Cc: Greg KH <gregkh@linuxfoundation.org>, Bob Liu <lliubbo@gmail.com>, linux-mm@kvack.org, ngupta@vflare.org, akpm@linux-foundation.org, sjenning@linux.vnet.ibm.com, riel@redhat.com, mgorman@suse.de, kyungmin.park@samsung.com, p.sarna@partner.samsung.com, barry.song@csr.com, penberg@kernel.org

On Tue, Aug 06, 2013 at 10:24:20PM +0800, Bob Liu wrote:
> Hi Greg,
> 
> On 08/06/2013 09:58 PM, Greg KH wrote:
> > On Tue, Aug 06, 2013 at 07:36:13PM +0800, Bob Liu wrote:
> >> Dan Magenheimer extended zcache supporting both file pages and anonymous pages.
> >> It's located in drivers/staging/zcache now. But the current version of zcache is
> >> too complicated to be merged into upstream.
> > 
> > Really?  If this is so, I'll just go delete zcache now, I don't want to
> > lug around dead code that will never be merged.
> > 
> 
> Zcache in staging have a zbud allocation which is almost the same as
> mm/zbud.c but with different API and have a frontswap backend like
> mm/zswap.c.
> So I'd prefer reuse mm/zbud.c and mm/zswap.c for a generic memory
> compression solution.
> Which means in that case, zcache in staging = mm/zswap.c + mm/zcache.c +
> mm/zbud.c.
> 
> But I'm not sure if there are any existing users of zcache in staging,
> if not I can delete zcache from staging in my next version of this
> mm/zcache.c series.

I think the Samsung folks are using it (zcache).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 37A756B0036
	for <linux-mm@kvack.org>; Mon, 12 Aug 2013 18:10:06 -0400 (EDT)
Date: Mon, 12 Aug 2013 15:10:04 -0700
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH v2 0/4] zcache: a compressed file page cache
Message-ID: <20130812221004.GA18287@kroah.com>
References: <1375788977-12105-1-git-send-email-bob.liu@oracle.com>
 <20130806135800.GC1048@kroah.com>
 <52010714.2090707@oracle.com>
 <20130812121908.GA3196@phenom.dumpdata.com>
 <20130812123002.GA23773@hacker.(null)>
 <20130812132310.GB3318@phenom.dumpdata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20130812132310.GB3318@phenom.dumpdata.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Wanpeng Li <liwanp@linux.vnet.ibm.com>, Bob Liu <bob.liu@oracle.com>, Bob Liu <lliubbo@gmail.com>, linux-mm@kvack.org, ngupta@vflare.org, akpm@linux-foundation.org, sjenning@linux.vnet.ibm.com, riel@redhat.com, mgorman@suse.de, kyungmin.park@samsung.com, p.sarna@partner.samsung.com, barry.song@csr.com, penberg@kernel.org

On Mon, Aug 12, 2013 at 09:23:10AM -0400, Konrad Rzeszutek Wilk wrote:
> Greg, since the Samsung folks are not using it, and we (Oracle) can
> patch our distro kernel to provide smorgasbord of zcache2, zswap
> and zcache3, even zcache1 if needed. I think it is safe to
> delete staging/zcache and focus on getting the zcache3 (Bob's
> patchset) upstream.

Ok, now deleted, thanks!

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

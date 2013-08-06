Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 28B1E6B0031
	for <linux-mm@kvack.org>; Tue,  6 Aug 2013 09:57:56 -0400 (EDT)
Date: Tue, 6 Aug 2013 21:58:00 +0800
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH v2 0/4] zcache: a compressed file page cache
Message-ID: <20130806135800.GC1048@kroah.com>
References: <1375788977-12105-1-git-send-email-bob.liu@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1375788977-12105-1-git-send-email-bob.liu@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: linux-mm@kvack.org, ngupta@vflare.org, akpm@linux-foundation.org, konrad.wilk@oracle.com, sjenning@linux.vnet.ibm.com, riel@redhat.com, mgorman@suse.de, kyungmin.park@samsung.com, p.sarna@partner.samsung.com, barry.song@csr.com, penberg@kernel.org, Bob Liu <bob.liu@oracle.com>

On Tue, Aug 06, 2013 at 07:36:13PM +0800, Bob Liu wrote:
> Dan Magenheimer extended zcache supporting both file pages and anonymous pages.
> It's located in drivers/staging/zcache now. But the current version of zcache is
> too complicated to be merged into upstream.

Really?  If this is so, I'll just go delete zcache now, I don't want to
lug around dead code that will never be merged.

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

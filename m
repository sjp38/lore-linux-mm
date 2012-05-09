Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id DC84A6B0044
	for <linux-mm@kvack.org>; Wed,  9 May 2012 12:54:39 -0400 (EDT)
From: Arnd Bergmann <arnd.bergmann@linaro.org>
Subject: Re: [PATCH v2 01/16] FS: Added demand paging markers to filesystem
Date: Wed, 9 May 2012 16:54:30 +0000
References: <1336054995-22988-1-git-send-email-svenkatr@ti.com> <201205091359.40554.arnd.bergmann@linaro.org> <20120509150343.GB14916@infradead.org>
In-Reply-To: <20120509150343.GB14916@infradead.org>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201205091654.30277.arnd.bergmann@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Dave Chinner <david@fromorbit.com>, "S, Venkatraman" <svenkatr@ti.com>, linux-mmc@vger.kernel.org, cjb@laptop.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-omap@vger.kernel.org, linux-kernel@vger.kernel.org, alex.lemberg@sandisk.com, ilan.smith@sandisk.com, lporzio@micron.com, rmk+kernel@arm.linux.org.uk

On Wednesday 09 May 2012, Christoph Hellwig wrote:
> On Wed, May 09, 2012 at 01:59:40PM +0000, Arnd Bergmann wrote:
> > My feeling is that we should just treat every (REQ_SYNC | REQ_READ)
> > request the same and let them interrupt long-running writes,
> > independent of whether it's REQ_META or demand paging.
> 
> It's funny that the CFQ scheduler used to boost metadata reads that
> have REQ_META set - in fact it still does for those filesystems using
> the now split out REQ_PRIO.

That certainly sounds more sensible than the opposite.

Of course, this is somewhat unrelated to the question of prioritizing
reads over any writes that are already started. IMHO It would be
pointless to only stop the write in order to do a REQ_PRIO read but
not any other read.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

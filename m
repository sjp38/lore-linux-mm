Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id C79BA6B0069
	for <linux-mm@kvack.org>; Wed, 16 Jan 2013 13:35:25 -0500 (EST)
Date: Wed, 16 Jan 2013 13:35:18 -0500
From: Jason Cooper <jason@lakedaemon.net>
Subject: Re: [PATCH] ata: sata_mv: fix sg_tbl_pool alignment
Message-ID: <20130116183518.GL25500@titan.lakedaemon.net>
References: <20130115175020.GA3764@kroah.com>
 <20130115201617.GC25500@titan.lakedaemon.net>
 <20130115215602.GF25500@titan.lakedaemon.net>
 <50F5F1B7.3040201@web.de>
 <20130116024014.GH25500@titan.lakedaemon.net>
 <50F61D86.4020801@web.de>
 <50F66B1B.40301@web.de>
 <20130116155045.GI25500@titan.lakedaemon.net>
 <50F6DDF7.9080605@web.de>
 <20130116175203.GK25500@titan.lakedaemon.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130116175203.GK25500@titan.lakedaemon.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Soeren Moch <smoch@web.de>
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>, Andrew Lunn <andrew@lunn.ch>, Arnd Bergmann <arnd@arndb.de>, linux-arm-kernel@lists.infradead.org, Greg KH <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>, linaro-mm-sig@lists.linaro.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>

> > >On Wed, Jan 16, 2013 at 09:55:55AM +0100, Soeren Moch wrote:
> > >>I don't want to say that Mareks patch is wrong, probably it triggers a
> > >>bug somewhere else! (in em28xx?)

Could you send the output of:

lsusb -v -d VEND:PROD

for the em28xx?

thx,

Jason.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

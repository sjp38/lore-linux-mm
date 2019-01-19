Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 21A148E0002
	for <linux-mm@kvack.org>; Sat, 19 Jan 2019 09:04:55 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id v16so8158048wru.8
        for <linux-mm@kvack.org>; Sat, 19 Jan 2019 06:04:55 -0800 (PST)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id p3si60866715wrv.158.2019.01.19.06.04.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 19 Jan 2019 06:04:53 -0800 (PST)
Date: Sat, 19 Jan 2019 15:04:52 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: use generic DMA mapping code in powerpc V4
Message-ID: <20190119140452.GA25198@lst.de>
References: <871403f2-fa7d-de15-89eb-070432e15c69@xenosoft.de> <20190118112842.GA9115@lst.de> <a2ca0118-5915-8b1c-7cfa-71cb4b43eaa6@xenosoft.de> <20190118121810.GA13327@lst.de> <eceebeda-0e18-00f6-06e7-def2eb0aa961@xenosoft.de> <20190118125500.GA15657@lst.de> <e11e61b1-6468-122e-fc2b-3b3f857186bb@xenosoft.de> <f39d4fc6-7e4e-9132-c03f-59f1b52260e0@xenosoft.de> <b9e5e081-a3cc-2625-4e08-2d55c2ba224b@xenosoft.de> <20190119130222.GA24346@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190119130222.GA24346@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian Zigotzky <chzigotzky@xenosoft.de>
Cc: Christoph Hellwig <hch@lst.de>, linux-arch@vger.kernel.org, Darren Stevens <darren@stevens-zone.net>, linux-kernel@vger.kernel.org, Julian Margetson <runaway@candw.ms>, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Paul Mackerras <paulus@samba.org>, Olof Johansson <olof@lixom.net>, linuxppc-dev@lists.ozlabs.org

On Sat, Jan 19, 2019 at 02:02:22PM +0100, Christoph Hellwig wrote:
> Interesting.  This suggest it is related to the use of ZONE_DMA by
> the FSL SOCs that your board uses.  Let me investigate this a bit more.

As a hack to check that theory I've pushed a new commit to the
powerpc-dma.6-debug branch to use old powerpc GFP_DMA selection
with the new dma direct code:

http://git.infradead.org/users/hch/misc.git/commitdiff/5c532d07c2f3c3972104de505d06b8d85f403f06

And another one that drops the addressability checks that powerpc
never had:

http://git.infradead.org/users/hch/misc.git/commitdiff/18e7629b38465ca98f8e7eed639123a13ac3b669

Can you first test with both patches, and then just with the first
in case that worked?

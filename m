Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 100048E0002
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 02:36:25 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id v16so15287774wru.8
        for <linux-mm@kvack.org>; Wed, 02 Jan 2019 23:36:25 -0800 (PST)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id k124si27075984wmd.157.2019.01.02.23.36.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Jan 2019 23:36:23 -0800 (PST)
Date: Thu, 3 Jan 2019 08:36:22 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: use generic DMA mapping code in powerpc V4
Message-ID: <20190103073622.GA24323@lst.de>
References: <2242B4B2-6311-492E-BFF9-6740E36EC6D4@xenosoft.de> <84558d7f-5a7f-5219-0c3a-045e6b4c494f@xenosoft.de> <20181213091021.GA2106@lst.de> <835bd119-081e-a5ea-1899-189d439c83d6@xenosoft.de> <76bc684a-b4d2-1d26-f18d-f5c9ba65978c@xenosoft.de> <20181213112511.GA4574@lst.de> <e109de27-f4af-147d-dc0e-067c8bafb29b@xenosoft.de> <ad5a5a8a-d232-d523-a6f7-e9377fc3857b@xenosoft.de> <e60d6ca3-860c-f01d-8860-c5e022ec7179@xenosoft.de> <008c981e-bdd2-21a7-f5f7-c57e4850ae9a@xenosoft.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <008c981e-bdd2-21a7-f5f7-c57e4850ae9a@xenosoft.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian Zigotzky <chzigotzky@xenosoft.de>
Cc: Christoph Hellwig <hch@lst.de>, linux-arch@vger.kernel.org, Darren Stevens <darren@stevens-zone.net>, linux-kernel@vger.kernel.org, Julian Margetson <runaway@candw.ms>, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Paul Mackerras <paulus@samba.org>, Olof Johansson <olof@lixom.net>, linuxppc-dev@lists.ozlabs.org

Hi Christian,

happy new year and I hope you had a few restful deays off.

I've pushed a new tree to:

   git://git.infradead.org/users/hch/misc.git powerpc-dma.6

Gitweb:

   http://git.infradead.org/users/hch/misc.git/shortlog/refs/heads/powerpc-dma.6

Which has been rebased to the latests Linus tree, which has a lot of
changes, and has also changed the patch split a bit to aid bisection.

I think 

   http://git.infradead.org/users/hch/misc.git/commitdiff/c446404b041130fbd9d1772d184f24715cf2362f

might be a good commit to re-start testing, then bisecting up to the
last commit using git bisect.

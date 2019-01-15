Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 31EF38E0002
	for <linux-mm@kvack.org>; Tue, 15 Jan 2019 08:36:00 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id x3so1017436wru.22
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 05:36:00 -0800 (PST)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id o6si11677874wrw.65.2019.01.15.05.35.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Jan 2019 05:35:58 -0800 (PST)
Date: Tue, 15 Jan 2019 14:35:58 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: use generic DMA mapping code in powerpc V4
Message-ID: <20190115133558.GA29225@lst.de>
References: <008c981e-bdd2-21a7-f5f7-c57e4850ae9a@xenosoft.de> <20190103073622.GA24323@lst.de> <71A251A5-FA06-4019-B324-7AED32F7B714@xenosoft.de> <1b0c5c21-2761-d3a3-651b-3687bb6ae694@xenosoft.de> <3504ee70-02de-049e-6402-2d530bf55a84@xenosoft.de> <23284859-bf0a-9cd5-a480-2a7fd7802056@xenosoft.de> <075f70e3-7a4a-732f-b501-05a1a8e3c853@xenosoft.de> <b04d08ea-61f9-3212-b9a3-ad79e3b8bd05@xenosoft.de> <21f72a6a-9095-7034-f169-95e876228b2a@xenosoft.de> <27148ac2-2a92-5536-d886-2c0971ab43d9@xenosoft.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <27148ac2-2a92-5536-d886-2c0971ab43d9@xenosoft.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian Zigotzky <chzigotzky@xenosoft.de>
Cc: Christoph Hellwig <hch@lst.de>, linux-arch@vger.kernel.org, Darren Stevens <darren@stevens-zone.net>, linux-kernel@vger.kernel.org, Julian Margetson <runaway@candw.ms>, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Paul Mackerras <paulus@samba.org>, Olof Johansson <olof@lixom.net>, linuxppc-dev@lists.ozlabs.org

On Tue, Jan 15, 2019 at 11:55:25AM +0100, Christian Zigotzky wrote:
> Next step: 21074ef03c0816ae158721a78cabe9035938dddd (powerpc/dma: use the 
> generic direct mapping bypass)
>
> git clone git://git.infradead.org/users/hch/misc.git -b powerpc-dma.6 a
>
> git checkout 21074ef03c0816ae158721a78cabe9035938dddd
>
> I was able to compile the kernel for the AmigaOne X1000 (Nemo board with PA 
> Semi PA6T-1682M SoC). It boots but the PA Semi onboard ethernet doesn't 
> work.

Thanks.  But we are exactly missing the steps that are relevant.  I've
pushed a fixed up powerpc-dma.6 tree, which will only change starting from
the first commit that didn't link.

The first commit that changed from the old one is this one:

http://git.infradead.org/users/hch/misc.git/commitdiff/257002094bc5935dd63207a380d9698ab81f0775

which was that one that your compile failed on first.

Thanks again for all your work!

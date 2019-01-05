Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 96F0A8E00F9
	for <linux-mm@kvack.org>; Sat,  5 Jan 2019 11:04:02 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id y1so17336358wrd.7
        for <linux-mm@kvack.org>; Sat, 05 Jan 2019 08:04:02 -0800 (PST)
Received: from mo6-p02-ob.smtp.rzone.de (mo6-p02-ob.smtp.rzone.de. [2a01:238:20a:202:5302::8])
        by mx.google.com with ESMTPS id p4si33325595wrh.452.2019.01.05.08.04.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 05 Jan 2019 08:04:01 -0800 (PST)
Subject: Re: use generic DMA mapping code in powerpc V4
From: Christian Zigotzky <chzigotzky@xenosoft.de>
References: <2242B4B2-6311-492E-BFF9-6740E36EC6D4@xenosoft.de>
 <84558d7f-5a7f-5219-0c3a-045e6b4c494f@xenosoft.de>
 <20181213091021.GA2106@lst.de>
 <835bd119-081e-a5ea-1899-189d439c83d6@xenosoft.de>
 <76bc684a-b4d2-1d26-f18d-f5c9ba65978c@xenosoft.de>
 <20181213112511.GA4574@lst.de>
 <e109de27-f4af-147d-dc0e-067c8bafb29b@xenosoft.de>
 <ad5a5a8a-d232-d523-a6f7-e9377fc3857b@xenosoft.de>
 <e60d6ca3-860c-f01d-8860-c5e022ec7179@xenosoft.de>
 <008c981e-bdd2-21a7-f5f7-c57e4850ae9a@xenosoft.de>
 <20190103073622.GA24323@lst.de>
 <71A251A5-FA06-4019-B324-7AED32F7B714@xenosoft.de>
Message-ID: <1b0c5c21-2761-d3a3-651b-3687bb6ae694@xenosoft.de>
Date: Sat, 5 Jan 2019 17:03:52 +0100
MIME-Version: 1.0
In-Reply-To: <71A251A5-FA06-4019-B324-7AED32F7B714@xenosoft.de>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: de-DE
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-arch@vger.kernel.org, Darren Stevens <darren@stevens-zone.net>, linux-kernel@vger.kernel.org, Julian Margetson <runaway@candw.ms>, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Paul Mackerras <paulus@samba.org>, Olof Johansson <olof@lixom.net>, linuxppc-dev@lists.ozlabs.org

Next step: c446404b041130fbd9d1772d184f24715cf2362f (powerpc/dma: remove 
dma_nommu_mmap_coherent)

git clone git://git.infradead.org/users/hch/misc.git -b powerpc-dma.6 a

git checkout c446404b041130fbd9d1772d184f24715cf2362f

Output:

Note: checking out 'c446404b041130fbd9d1772d184f24715cf2362f'.

You are in 'detached HEAD' state. You can look around, make experimental
changes and commit them, and you can discard any commits you make in this
state without impacting any branches by performing another checkout.

If you want to create a new branch to retain commits you create, you may
do so (now or later) by using -b with the checkout command again. Example:

   git checkout -b <new-branch-name>

HEAD is now at c446404... powerpc/dma: remove dma_nommu_mmap_coherent

-----

Link to the Git: 
http://git.infradead.org/users/hch/misc.git/shortlog/refs/heads/powerpc-dma.6

Result: PASEMI onboard ethernet works and the X5000 (P5020 board) boots.

-- Christian

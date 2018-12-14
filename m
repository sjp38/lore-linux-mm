Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 051348E01D1
	for <linux-mm@kvack.org>; Fri, 14 Dec 2018 07:00:34 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id j30so1985463wre.16
        for <linux-mm@kvack.org>; Fri, 14 Dec 2018 04:00:33 -0800 (PST)
Received: from mo6-p01-ob.smtp.rzone.de (mo6-p01-ob.smtp.rzone.de. [2a01:238:20a:202:5301::10])
        by mx.google.com with ESMTPS id w196si3162749wmf.115.2018.12.14.04.00.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Dec 2018 04:00:32 -0800 (PST)
Subject: Re: use generic DMA mapping code in powerpc V4
From: Christian Zigotzky <chzigotzky@xenosoft.de>
References: <1ecb7692-f3fb-a246-91f9-2db1b9496305@xenosoft.de>
 <6c997c03-e072-97a9-8ae0-38a4363df919@xenosoft.de>
 <4cfb3f26-74e1-db01-b014-759f188bb5a6@xenosoft.de>
 <82879d3f-83de-6438-c1d6-49c571dcb671@xenosoft.de>
 <20181212141556.GA4801@lst.de>
 <2242B4B2-6311-492E-BFF9-6740E36EC6D4@xenosoft.de>
 <84558d7f-5a7f-5219-0c3a-045e6b4c494f@xenosoft.de>
 <20181213091021.GA2106@lst.de>
 <835bd119-081e-a5ea-1899-189d439c83d6@xenosoft.de>
 <76bc684a-b4d2-1d26-f18d-f5c9ba65978c@xenosoft.de>
 <20181213112511.GA4574@lst.de>
 <e109de27-f4af-147d-dc0e-067c8bafb29b@xenosoft.de>
 <ad5a5a8a-d232-d523-a6f7-e9377fc3857b@xenosoft.de>
 <e60d6ca3-860c-f01d-8860-c5e022ec7179@xenosoft.de>
Message-ID: <008c981e-bdd2-21a7-f5f7-c57e4850ae9a@xenosoft.de>
Date: Fri, 14 Dec 2018 13:00:26 +0100
MIME-Version: 1.0
In-Reply-To: <e60d6ca3-860c-f01d-8860-c5e022ec7179@xenosoft.de>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: de-DE
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-arch@vger.kernel.org, Darren Stevens <darren@stevens-zone.net>, linux-kernel@vger.kernel.org, Julian Margetson <runaway@candw.ms>, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Paul Mackerras <paulus@samba.org>, Olof Johansson <olof@lixom.net>, linuxppc-dev@lists.ozlabs.org

On 12 December 2018 at 3:15PM, Christoph Hellwig wrote:
 > Thanks for bisecting.  I've spent some time going over the conversion
 > but can't really pinpoint it.  I have three little patches that switch
 > parts of the code to the generic version.  This is on top of the
 > last good commmit (977706f9755d2d697aa6f45b4f9f0e07516efeda).
 >
 > Can you check with whіch one things stop working?

Hello Christoph,

Great news! All your patches work!

I tested all your patches (including the patch '0004-alloc-free.patch' 
today) and the PASEMI onboard ethernet works and the P5020 board boots 
without any problems. Thank you for your work!
I have a few days off. That means, I will work less and only for the 
A-EON first level Linux support. I can test again on Thursday next week.

Have a nice weekend!

Cheers,
Christian

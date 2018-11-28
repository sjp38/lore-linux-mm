Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5AA826B4EB5
	for <linux-mm@kvack.org>; Wed, 28 Nov 2018 15:03:09 -0500 (EST)
Received: by mail-wm1-f70.google.com with SMTP id d126so4254003wme.2
        for <linux-mm@kvack.org>; Wed, 28 Nov 2018 12:03:09 -0800 (PST)
Received: from mo6-p01-ob.smtp.rzone.de (mo6-p01-ob.smtp.rzone.de. [2a01:238:20a:202:5301::7])
        by mx.google.com with ESMTPS id r16si6576326wrr.211.2018.11.28.12.03.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Nov 2018 12:03:07 -0800 (PST)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (1.0)
Subject: Re: use generic DMA mapping code in powerpc V4
From: Christian Zigotzky <chzigotzky@xenosoft.de>
In-Reply-To: <535776df-dea3-eb26-6bf3-83f225e977df@xenosoft.de>
Date: Wed, 28 Nov 2018 21:02:51 +0100
Content-Transfer-Encoding: quoted-printable
Message-Id: <7B91760F-AFC3-4C8C-9B9F-FA0E9AD76B0C@xenosoft.de>
References: <20181114082314.8965-1-hch@lst.de> <20181127074253.GB30186@lst.de> <87zhttfonk.fsf@concordia.ellerman.id.au> <535776df-dea3-eb26-6bf3-83f225e977df@xenosoft.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>, Christoph Hellwig <hch@lst.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>
Cc: linux-arch@vger.kernel.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org

I will compile and test the kernel from the following Git on my PowerPC mach=
ines.

http://git.infradead.org/users/hch/misc.git

On 28 November 2018 at 12:05PM, Michael Ellerman wrote:
Nothing specific yet.

I'm a bit worried it might break one of the many old obscure platforms
we have that aren't well tested.

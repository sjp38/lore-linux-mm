Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7DE256B0009
	for <linux-mm@kvack.org>; Sat, 28 Apr 2018 04:33:06 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id m13-v6so3221629pgp.5
        for <linux-mm@kvack.org>; Sat, 28 Apr 2018 01:33:06 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id v12-v6si3227482plg.180.2018.04.28.01.33.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 28 Apr 2018 01:33:05 -0700 (PDT)
Date: Sat, 28 Apr 2018 01:33:03 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [LSF/MM TOPIC NOTES] x86 ZONE_DMA love
Message-ID: <20180428083303.GB31684@infradead.org>
References: <20180426215406.GB27853@wotan.suse.de>
 <20180427053556.GB11339@infradead.org>
 <20180427071843.GB17484@dhcp22.suse.cz>
 <alpine.DEB.2.20.1804271103160.11686@nuc-kabylake>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1804271103160.11686@nuc-kabylake>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Michal Hocko <mhocko@kernel.org>, Christoph Hellwig <hch@infradead.org>, "Luis R. Rodriguez" <mcgrof@kernel.org>, linux-mm@kvack.org, Jan Kara <jack@suse.cz>, matthew@wil.cx, x86@kernel.org, luto@amacapital.net, martin.petersen@oracle.com, jthumshirn@suse.de, broonie@kernel.org, linux-spi@vger.kernel.org, linux-scsi@vger.kernel.org, linux-kernel@vger.kernel.org, "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>

On Fri, Apr 27, 2018 at 11:07:07AM -0500, Christopher Lameter wrote:
> Well it looks like what we are using it for is to force allocation from
> low physical memory if we fail to obtain proper memory through a normal
> channel.  The use of ZONE_DMA is only there for emergency purposes.
> I think we could subsitute ZONE_DMA32 on x87 without a problem.
> 
> Which means that ZONE_DMA has no purpose anymore.
> 
> Can we make ZONE_DMA on x86 refer to the low 32 bit physical addresses
> instead and remove ZONE_DMA32?

While < 32-bit allocations are much more common there are plenty
of requirements for < 24-bit or other weird masks still.

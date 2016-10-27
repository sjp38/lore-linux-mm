Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 29E526B0270
	for <linux-mm@kvack.org>; Thu, 27 Oct 2016 08:32:45 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id xx10so20053441pac.2
        for <linux-mm@kvack.org>; Thu, 27 Oct 2016 05:32:45 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id h4si7729903pfk.227.2016.10.27.05.32.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Oct 2016 05:32:44 -0700 (PDT)
Date: Thu, 27 Oct 2016 05:32:19 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 0/3] iopmem : A block device for PCIe memory
Message-ID: <20161027123219.GA757@infradead.org>
References: <1476826937-20665-1-git-send-email-sbates@raithlin.com>
 <CAPcyv4gJ_c-6s2BUjsu6okR1EF53R+KNuXnOc5jv0fuwJaa3cQ@mail.gmail.com>
 <20161019184814.GC16550@cgy1-donard.priv.deltatee.com>
 <20161020232239.GQ23194@dastard>
 <20161021095714.GA12209@infradead.org>
 <76e957c9-8002-5a46-8111-269bb0401718@grimberg.me>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <76e957c9-8002-5a46-8111-269bb0401718@grimberg.me>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sagi Grimberg <sagi@grimberg.me>
Cc: Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, jgunthorpe@obsidianresearch.com, sbates@raithin.com, "Raj, Ashok" <ashok.raj@intel.com>, haggaie@mellanox.com, linux-rdma@vger.kernel.org, "linux-nvdimm@lists.01.org" <linux-nvdimm@ml01.01.org>, Jonathan Corbet <corbet@lwn.net>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, jim.macdonald@everspin.com, Stephen Bates <sbates@raithlin.com>, linux-block@vger.kernel.org, Linux MM <linux-mm@kvack.org>, Jens Axboe <axboe@fb.com>, David Woodhouse <dwmw2@infradead.org>

On Thu, Oct 27, 2016 at 01:22:49PM +0300, Sagi Grimberg wrote:
> Christoph, did you manage to leap to the future and solve the
> RDMA persistency hole? :)
> 
> e.g. what happens with O_DSYNC in this model? Or you did
> a message exchange for commits?

Yes, pNFS calls this the layoutcommit.  That being said once we get a RDMA
commit or flush operation we could easily make the layoutcommit optional
for some operations.  There already is a precedence for the in the
flexfiles layout specification.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

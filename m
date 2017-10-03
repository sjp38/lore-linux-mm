Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7F6056B025E
	for <linux-mm@kvack.org>; Tue,  3 Oct 2017 10:59:23 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id j70so1858366pgc.5
        for <linux-mm@kvack.org>; Tue, 03 Oct 2017 07:59:23 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id b29si6268640pfh.497.2017.10.03.07.59.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Oct 2017 07:59:22 -0700 (PDT)
Date: Tue, 3 Oct 2017 07:59:21 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v4 1/5] cramfs: direct memory access support
Message-ID: <20171003145921.GA9954@infradead.org>
References: <20170927233224.31676-1-nicolas.pitre@linaro.org>
 <20170927233224.31676-2-nicolas.pitre@linaro.org>
 <20171001082955.GA17116@infradead.org>
 <nycvar.YSQ.7.76.1710011659530.5407@knanqh.ubzr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <nycvar.YSQ.7.76.1710011659530.5407@knanqh.ubzr>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicolas Pitre <nicolas.pitre@linaro.org>
Cc: Christoph Hellwig <hch@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-embedded@vger.kernel.org, linux-kernel@vger.kernel.org, Chris Brandt <Chris.Brandt@renesas.com>, linux-mtd@lists.infradead.org, devicetree@vger.kernel.org

On Sun, Oct 01, 2017 at 06:27:11PM -0400, Nicolas Pitre wrote:
> If you prefer, the physical address could be specified with a Kconfig 
> symbol just like the kernel link address. Personally I think it is best 
> to keep it along with the other root mount args. But going all the way 
> with a dynamic driver binding interface and a dummy intermediate name is 
> like using a sledge hammer to kill an ant: it will work of course, but 
> given the context it is prone to errors due to the added manipulations 
> mentioned previously ... and a tad overkill.

As soon as a kernel enables CRAMFS_PHYSMEM this mount option is
available, so you don't just need to think of your use case.

The normal way for doings this would be to specify it in the device
tree.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

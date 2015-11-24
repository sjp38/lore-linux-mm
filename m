Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 897346B0038
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 02:50:49 -0500 (EST)
Received: by wmww144 with SMTP id w144so126628455wmw.1
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 23:50:49 -0800 (PST)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id y131si24995230wme.63.2015.11.23.23.50.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Nov 2015 23:50:48 -0800 (PST)
Date: Tue, 24 Nov 2015 08:50:47 +0100
From: "hch@lst.de" <hch@lst.de>
Subject: Re: + arc-convert-to-dma_map_ops.patch added to -mm tree
Message-ID: <20151124075047.GA29572@lst.de>
References: <564b9e3a.DaXj5xWV8Mzu1fPX%akpm@linux-foundation.org> <C2D7FE5348E1B147BCA15975FBA23075F44D2EEF@IN01WEMBXA.internal.synopsys.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <C2D7FE5348E1B147BCA15975FBA23075F44D2EEF@IN01WEMBXA.internal.synopsys.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Cc: "hch@lst.de" <hch@lst.de>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, arcml <linux-snps-arc@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, linux-next <linux-next@vger.kernel.org>, Anton Kolesov <Anton.Kolesov@synopsys.com>

Hi Vineet,

the original version went through the buildbot, which succeeded.  It seems
like the official buildbot does not support arc, and might benefit from
helping to set up an arc environment.  However in the meantime Guenther
send me output from his buildbot and I sent a fix for arc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

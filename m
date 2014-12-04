Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f46.google.com (mail-qa0-f46.google.com [209.85.216.46])
	by kanga.kvack.org (Postfix) with ESMTP id C65F66B007B
	for <linux-mm@kvack.org>; Thu,  4 Dec 2014 15:45:38 -0500 (EST)
Received: by mail-qa0-f46.google.com with SMTP id n8so6383346qaq.5
        for <linux-mm@kvack.org>; Thu, 04 Dec 2014 12:45:38 -0800 (PST)
Received: from mail-qc0-x22b.google.com (mail-qc0-x22b.google.com. [2607:f8b0:400d:c01::22b])
        by mx.google.com with ESMTPS id g89si25305874qgg.113.2014.12.04.12.45.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 04 Dec 2014 12:45:38 -0800 (PST)
Received: by mail-qc0-f171.google.com with SMTP id r5so13391414qcx.16
        for <linux-mm@kvack.org>; Thu, 04 Dec 2014 12:45:37 -0800 (PST)
Date: Thu, 4 Dec 2014 15:45:34 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC v2] percpu: Add a separate function to merge free areas
Message-ID: <20141204204534.GE4080@htj.dyndns.org>
References: <547E3E57.3040908@ixiacom.com>
 <20141204175713.GE2995@htj.dyndns.org>
 <5480BFAA.2020106@ixiacom.com>
 <alpine.DEB.2.11.1412041426230.14577@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1412041426230.14577@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Leonard Crestez <lcrestez@ixiacom.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sorin Dumitru <sdumitru@ixiacom.com>

Hello, Christoph.

On Thu, Dec 04, 2014 at 02:28:10PM -0600, Christoph Lameter wrote:
> Well this is not a common use case and that is not what the per cpu
> allocator was designed for. There is bound to be signifcant fragmentation
> with the current design. The design was for rare allocations when
> structures are initialized.

My unverified gut feeling is that fragmentation prolly is a lot less
of a problem for percpu allocator given that most percpu allocations
are fairly small.  On the other hand, we do wanna pack them tight as
percpu memory is really expensive space-wise.  I could be wrong tho.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

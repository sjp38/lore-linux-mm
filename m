Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3162B6B0038
	for <linux-mm@kvack.org>; Tue, 28 Nov 2017 13:47:52 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id p144so632555itc.9
        for <linux-mm@kvack.org>; Tue, 28 Nov 2017 10:47:52 -0800 (PST)
Received: from resqmta-ch2-01v.sys.comcast.net (resqmta-ch2-01v.sys.comcast.net. [69.252.207.33])
        by mx.google.com with ESMTPS id g11si23199365iob.253.2017.11.28.10.47.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Nov 2017 10:47:51 -0800 (PST)
Date: Tue, 28 Nov 2017 12:46:50 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH 01/23] slab: make kmalloc_index() return "unsigned int"
In-Reply-To: <20171127163658.44c3121e47ea3b2cf230c36b@linux-foundation.org>
Message-ID: <alpine.DEB.2.20.1711281246280.10580@nuc-kabylake>
References: <20171123221628.8313-1-adobriyan@gmail.com> <20171127163658.44c3121e47ea3b2cf230c36b@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexey Dobriyan <adobriyan@gmail.com>, linux-mm@kvack.org, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com

On Mon, 27 Nov 2017, Andrew Morton wrote:

> > 	add/remove: 0/0 grow/shrink: 0/2 up/down: 0/-6 (-6)
> > 	Function                                     old     new   delta
> > 	rtsx_scsi_handler                           9116    9114      -2
> > 	vnic_rq_alloc                                424     420      -4
>
> While I applaud the use of accurate and appropriate types, that's one
> heck of a big patch series.  What do the slab maintainers think?

Run some regression tests and make sure that we did not get some false
aliasing?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id A0AC16B0003
	for <linux-mm@kvack.org>; Tue,  6 Mar 2018 13:43:28 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id y83so43092ita.5
        for <linux-mm@kvack.org>; Tue, 06 Mar 2018 10:43:28 -0800 (PST)
Received: from resqmta-ch2-08v.sys.comcast.net (resqmta-ch2-08v.sys.comcast.net. [2001:558:fe21:29:69:252:207:40])
        by mx.google.com with ESMTPS id n36si10945506ioe.138.2018.03.06.10.43.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Mar 2018 10:43:27 -0800 (PST)
Date: Tue, 6 Mar 2018 12:43:26 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH 12/25] slub: make ->reserved unsigned int
In-Reply-To: <20180305200730.15812-12-adobriyan@gmail.com>
Message-ID: <alpine.DEB.2.20.1803061242530.29393@nuc-kabylake>
References: <20180305200730.15812-1-adobriyan@gmail.com> <20180305200730.15812-12-adobriyan@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: akpm@linux-foundation.org, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org

On Mon, 5 Mar 2018, Alexey Dobriyan wrote:

> ->reserved is either 0 or sizeof(struct rcu_head), can't be negative.

Thus it should be size_t? ;-)

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

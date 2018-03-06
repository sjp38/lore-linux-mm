Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id C012C6B0010
	for <linux-mm@kvack.org>; Tue,  6 Mar 2018 13:52:35 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id m70so82743ioi.8
        for <linux-mm@kvack.org>; Tue, 06 Mar 2018 10:52:35 -0800 (PST)
Received: from resqmta-ch2-11v.sys.comcast.net (resqmta-ch2-11v.sys.comcast.net. [2001:558:fe21:29:69:252:207:43])
        by mx.google.com with ESMTPS id f14si6273758itc.2.2018.03.06.10.52.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Mar 2018 10:52:34 -0800 (PST)
Date: Tue, 6 Mar 2018 12:52:33 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH 24/25] slub: make size_from_object() return unsigned
 int
In-Reply-To: <20180305200730.15812-24-adobriyan@gmail.com>
Message-ID: <alpine.DEB.2.20.1803061252160.29393@nuc-kabylake>
References: <20180305200730.15812-1-adobriyan@gmail.com> <20180305200730.15812-24-adobriyan@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: akpm@linux-foundation.org, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org


Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

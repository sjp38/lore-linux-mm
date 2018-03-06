Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5EC396B0003
	for <linux-mm@kvack.org>; Tue,  6 Mar 2018 13:44:55 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id q4so61718ioh.4
        for <linux-mm@kvack.org>; Tue, 06 Mar 2018 10:44:55 -0800 (PST)
Received: from resqmta-ch2-04v.sys.comcast.net (resqmta-ch2-04v.sys.comcast.net. [2001:558:fe21:29:69:252:207:36])
        by mx.google.com with ESMTPS id w187si10718736iod.200.2018.03.06.10.44.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Mar 2018 10:44:54 -0800 (PST)
Date: Tue, 6 Mar 2018 12:44:53 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH 15/25] slub: make ->cpu_partial unsigned int
In-Reply-To: <20180305200730.15812-15-adobriyan@gmail.com>
Message-ID: <alpine.DEB.2.20.1803061244440.29393@nuc-kabylake>
References: <20180305200730.15812-1-adobriyan@gmail.com> <20180305200730.15812-15-adobriyan@gmail.com>
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

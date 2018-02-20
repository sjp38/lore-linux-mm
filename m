Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 425516B0005
	for <linux-mm@kvack.org>; Tue, 20 Feb 2018 09:56:14 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id w17so12779721iow.23
        for <linux-mm@kvack.org>; Tue, 20 Feb 2018 06:56:14 -0800 (PST)
Received: from resqmta-ch2-04v.sys.comcast.net (resqmta-ch2-04v.sys.comcast.net. [2001:558:fe21:29:69:252:207:36])
        by mx.google.com with ESMTPS id i3si609000iof.237.2018.02.20.06.56.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Feb 2018 06:56:13 -0800 (PST)
Date: Tue, 20 Feb 2018 08:56:11 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH] slab: fix /proc/slabinfo alignment
In-Reply-To: <BM1PR0101MB2083C73A6E7608B630CE4C26B1CF0@BM1PR0101MB2083.INDPRD01.PROD.OUTLOOK.COM>
Message-ID: <alpine.DEB.2.20.1802200855300.28634@nuc-kabylake>
References: <BM1PR0101MB2083C73A6E7608B630CE4C26B1CF0@BM1PR0101MB2083.INDPRD01.PROD.OUTLOOK.COM>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ? ? <mordorw@hotmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, 20 Feb 2018, ? ? wrote:

> /proc/slabinfo is not aligned, it is difficult to read, so correct it

How does it look on a terminal with 80 characters per line?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

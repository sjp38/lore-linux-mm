Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f45.google.com (mail-qe0-f45.google.com [209.85.128.45])
	by kanga.kvack.org (Postfix) with ESMTP id 39B0D6B0031
	for <linux-mm@kvack.org>; Tue,  3 Dec 2013 15:59:49 -0500 (EST)
Received: by mail-qe0-f45.google.com with SMTP id 6so15409704qea.32
        for <linux-mm@kvack.org>; Tue, 03 Dec 2013 12:59:49 -0800 (PST)
Received: from a9-111.smtp-out.amazonses.com (a9-111.smtp-out.amazonses.com. [54.240.9.111])
        by mx.google.com with ESMTP id el7si32475498qeb.105.2013.12.03.12.59.47
        for <linux-mm@kvack.org>;
        Tue, 03 Dec 2013 12:59:48 -0800 (PST)
Date: Tue, 3 Dec 2013 20:59:46 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: Slab BUG with DEBUG_* options
In-Reply-To: <alpine.SOC.1.00.1312032232210.25191@math.ut.ee>
Message-ID: <00000142ba4274a7-5ff9996c-6ce6-412e-9a06-37b12b501ddb-000000@email.amazonses.com>
References: <alpine.SOC.1.00.1311300125490.6363@math.ut.ee> <00000142b923d9de-2c71e0b6-7443-46c0-bbde-93a81b50ed37-000000@email.amazonses.com> <alpine.SOC.1.00.1312032232210.25191@math.ut.ee>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Meelis Roos <mroos@linux.ee>
Cc: Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Joonsoo Kim <js1304@gmail.com>

On Tue, 3 Dec 2013, Meelis Roos wrote:

> Kernel panic - not syncing: Creation of kmalloc slab (null) size=8388608
> failed. Reason -7

Same here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

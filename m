Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id BDFEF6B0071
	for <linux-mm@kvack.org>; Wed,  4 Jul 2012 08:58:11 -0400 (EDT)
Received: by obhx4 with SMTP id x4so9072656obh.14
        for <linux-mm@kvack.org>; Wed, 04 Jul 2012 05:58:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1340390729-2821-1-git-send-email-js1304@gmail.com>
References: <1340389359-2407-1-git-send-email-js1304@gmail.com>
	<1340390729-2821-1-git-send-email-js1304@gmail.com>
Date: Wed, 4 Jul 2012 21:58:10 +0900
Message-ID: <CAAmzW4O5Td0YdK-6WmnuLOcaK6GDF43U_gx8DpK1AWW0ePWScg@mail.gmail.com>
Subject: Re: [PATCH 1/3 v2] slub: prefetch next freelist pointer in __slab_alloc()
From: JoonSoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Eric Dumazet <eric.dumazet@gmail.com>, Joonsoo Kim <js1304@gmail.com>

Hi Pekka and Christoph.
Could you give me some comments for these patches?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

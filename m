Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id 71A276B0114
	for <linux-mm@kvack.org>; Wed,  6 Nov 2013 16:38:14 -0500 (EST)
Received: by mail-pb0-f49.google.com with SMTP id um15so97142pbc.36
        for <linux-mm@kvack.org>; Wed, 06 Nov 2013 13:38:13 -0800 (PST)
Received: from psmtp.com ([74.125.245.137])
        by mx.google.com with SMTP id mi5si529511pab.19.2013.11.06.13.38.12
        for <linux-mm@kvack.org>;
        Wed, 06 Nov 2013 13:38:13 -0800 (PST)
Date: Wed, 6 Nov 2013 21:38:10 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm/slub: Switch slub_debug kernel option to early_param
 to avoid boot panic
In-Reply-To: <20131106211604.GM5661@alberich>
Message-ID: <000001422f59e79e-ba0d30e2-fe7d-4e6f-9029-65dc5978fe60-000000@email.amazonses.com>
References: <20131106184529.GB5661@alberich> <000001422ed8406b-14bef091-eee0-4e0e-bcdd-a8909c605910-000000@email.amazonses.com> <20131106195417.GK5661@alberich> <20131106203429.GL5661@alberich> <20131106211604.GM5661@alberich>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andreas Herrmann <andreas.herrmann@calxeda.com>
Cc: Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Wed, 6 Nov 2013, Andreas Herrmann wrote:

> Would be nice, if your patch is pushed upstream asap.

Ok so this is a

Tested-by: Andreas Herrmann <andreas.herrmann@calxeda.com>

I think?

BTW Calxeda is a great product. Hope you get 64 bit running soon.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f182.google.com (mail-ie0-f182.google.com [209.85.223.182])
	by kanga.kvack.org (Postfix) with ESMTP id 6DEB86B00B4
	for <linux-mm@kvack.org>; Mon, 24 Nov 2014 12:17:25 -0500 (EST)
Received: by mail-ie0-f182.google.com with SMTP id x19so9234377ier.41
        for <linux-mm@kvack.org>; Mon, 24 Nov 2014 09:17:25 -0800 (PST)
Received: from resqmta-po-03v.sys.comcast.net (resqmta-po-03v.sys.comcast.net. [2001:558:fe16:19:96:114:154:162])
        by mx.google.com with ESMTPS id h7si5268983iga.21.2014.11.24.09.17.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 24 Nov 2014 09:17:24 -0800 (PST)
Date: Mon, 24 Nov 2014 11:17:22 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slub: fix confusing error messages in check_slab
In-Reply-To: <CAHkaATSEn9WMKJNRp5QvzPsno_vddtMXY39yvi=BGtb4M+Hqdw@mail.gmail.com>
Message-ID: <alpine.DEB.2.11.1411241117030.8951@gentwo.org>
References: <CAHkaATSEn9WMKJNRp5QvzPsno_vddtMXY39yvi=BGtb4M+Hqdw@mail.gmail.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Min-Hua Chen <orca.chen@gmail.com>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Mon, 24 Nov 2014, Min-Hua Chen wrote:

> In check_slab, s->name is passed incorrectly to the error
> messages. It will cause confusing error messages if the object
> check fails. This patch fix this bug by removing s->name.

I have seen a patch like thios before.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

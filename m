Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7D22D280298
	for <linux-mm@kvack.org>; Fri, 10 Nov 2017 11:02:50 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id z69so1511542ita.8
        for <linux-mm@kvack.org>; Fri, 10 Nov 2017 08:02:50 -0800 (PST)
Received: from resqmta-ch2-07v.sys.comcast.net (resqmta-ch2-07v.sys.comcast.net. [2001:558:fe21:29:69:252:207:39])
        by mx.google.com with ESMTPS id u68si7809755ioe.266.2017.11.10.08.02.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Nov 2017 08:02:49 -0800 (PST)
Date: Fri, 10 Nov 2017 10:02:47 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH] slub: Fix sysfs duplicate filename creation when
 slub_debug=O
In-Reply-To: <1510271512.11555.3.camel@mtkswgap22>
Message-ID: <alpine.DEB.2.20.1711100941030.29707@nuc-kabylake>
References: <1510023934-17517-1-git-send-email-miles.chen@mediatek.com> <alpine.DEB.2.20.1711070916480.18776@nuc-kabylake> <1510119138.17435.19.camel@mtkswgap22> <alpine.DEB.2.20.1711080903460.6161@nuc-kabylake> <1510217554.32371.17.camel@mtkswgap22>
 <alpine.DEB.2.20.1711090949250.12587@nuc-kabylake> <1510271512.11555.3.camel@mtkswgap22>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Miles Chen <miles.chen@mediatek.com>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, wsd_upstream@mediatek.com, linux-mediatek@lists.infradead.org

On Fri, 10 Nov 2017, Miles Chen wrote:

> By checking disable_higher_order_debug & (slub_debug &
> SLAB_NEVER_MERGE), we can detect if a cache is unmergeable but become
> mergeable because the disable_higher_order_debug=1 logic. Those kind of
> caches should be keep unmergeable.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

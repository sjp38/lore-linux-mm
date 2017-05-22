Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id CCF20831F4
	for <linux-mm@kvack.org>; Mon, 22 May 2017 11:24:36 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id e79so88863799ioi.6
        for <linux-mm@kvack.org>; Mon, 22 May 2017 08:24:36 -0700 (PDT)
Received: from resqmta-ch2-07v.sys.comcast.net (resqmta-ch2-07v.sys.comcast.net. [2001:558:fe21:29:69:252:207:39])
        by mx.google.com with ESMTPS id t8si18195568iof.81.2017.05.22.08.24.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 May 2017 08:24:36 -0700 (PDT)
Date: Mon, 22 May 2017 10:24:32 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 0/3] mm/slub: Fix unused function warnings
In-Reply-To: <20170519210036.146880-1-mka@chromium.org>
Message-ID: <alpine.DEB.2.20.1705221024090.11040@east.gentwo.org>
References: <20170519210036.146880-1-mka@chromium.org>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthias Kaehlcke <mka@chromium.org>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 19 May 2017, Matthias Kaehlcke wrote:

> This series fixes a bunch of warnings about unused functions in SLUB

Looks ok to me.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id C06CF6B0279
	for <linux-mm@kvack.org>; Thu, 25 May 2017 13:49:24 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id p24so131086960ioi.8
        for <linux-mm@kvack.org>; Thu, 25 May 2017 10:49:24 -0700 (PDT)
Received: from mail-io0-x22b.google.com (mail-io0-x22b.google.com. [2607:f8b0:4001:c06::22b])
        by mx.google.com with ESMTPS id r75si29760872iod.226.2017.05.25.10.49.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 May 2017 10:49:23 -0700 (PDT)
Received: by mail-io0-x22b.google.com with SMTP id o12so141609856iod.3
        for <linux-mm@kvack.org>; Thu, 25 May 2017 10:49:23 -0700 (PDT)
Date: Thu, 25 May 2017 10:49:21 -0700
From: Matthias Kaehlcke <mka@chromium.org>
Subject: Re: [patch] compiler, clang: suppress warning for unused static
 inline functions
Message-ID: <20170525174921.GU141096@google.com>
References: <alpine.DEB.2.10.1705241400510.49680@chino.kir.corp.google.com>
 <20170524212229.GR141096@google.com>
 <20170525055207.udcphnshuzl2gkps@gmail.com>
 <20170525161406.GT141096@google.com>
 <1495730933.29207.6.camel@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <1495730933.29207.6.camel@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: Ingo Molnar <mingo@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Douglas Anderson <dianders@chromium.org>, Mark Brown <broonie@kernel.org>, David Miller <davem@davemloft.net>

Hi Joe,

El Thu, May 25, 2017 at 09:48:53AM -0700 Joe Perches ha dit:

> On Thu, 2017-05-25 at 09:14 -0700, Matthias Kaehlcke wrote:
> > clang doesn't raise
> > warnings about unused static inline functions in headers.
> 
> Is any "#include" file a "header" to clang or only "*.h" files?
> 
> For instance:
> 
> The kernel has ~500 .c files that other .c files #include.
> Are unused inline functions in those .c files reported?

Any "#include" file is a "header" to clang, no warnings are generated
for unused inline functions in included .c files.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

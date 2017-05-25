Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id E5ED96B0279
	for <linux-mm@kvack.org>; Thu, 25 May 2017 12:48:58 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id i206so141744027ita.10
        for <linux-mm@kvack.org>; Thu, 25 May 2017 09:48:58 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0193.hostedemail.com. [216.40.44.193])
        by mx.google.com with ESMTPS id 79si29476707ior.125.2017.05.25.09.48.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 May 2017 09:48:58 -0700 (PDT)
Message-ID: <1495730933.29207.6.camel@perches.com>
Subject: Re: [patch] compiler, clang: suppress warning for unused static
 inline functions
From: Joe Perches <joe@perches.com>
Date: Thu, 25 May 2017 09:48:53 -0700
In-Reply-To: <20170525161406.GT141096@google.com>
References: <alpine.DEB.2.10.1705241400510.49680@chino.kir.corp.google.com>
	 <20170524212229.GR141096@google.com>
	 <20170525055207.udcphnshuzl2gkps@gmail.com>
	 <20170525161406.GT141096@google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthias Kaehlcke <mka@chromium.org>, Ingo Molnar <mingo@kernel.org>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Douglas Anderson <dianders@chromium.org>, Mark Brown <broonie@kernel.org>, David Miller <davem@davemloft.net>

On Thu, 2017-05-25 at 09:14 -0700, Matthias Kaehlcke wrote:
> clang doesn't raise
> warnings about unused static inline functions in headers.

Is any "#include" file a "header" to clang or only "*.h" files?

For instance:

The kernel has ~500 .c files that other .c files #include.
Are unused inline functions in those .c files reported?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

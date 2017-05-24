Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id AB4976B0292
	for <linux-mm@kvack.org>; Wed, 24 May 2017 17:32:08 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id m5so205835224pfc.1
        for <linux-mm@kvack.org>; Wed, 24 May 2017 14:32:08 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id g10si3493228plj.120.2017.05.24.14.32.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 May 2017 14:32:08 -0700 (PDT)
Date: Wed, 24 May 2017 14:32:05 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] compiler, clang: suppress warning for unused static
 inline functions
Message-Id: <20170524143205.cae1a02ab2ad7348c1a59e0c@linux-foundation.org>
In-Reply-To: <20170524212229.GR141096@google.com>
References: <alpine.DEB.2.10.1705241400510.49680@chino.kir.corp.google.com>
	<20170524212229.GR141096@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthias Kaehlcke <mka@chromium.org>
Cc: David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Douglas Anderson <dianders@chromium.org>, Mark Brown <broonie@kernel.org>, Ingo Molnar <mingo@kernel.org>, David Miller <davem@davemloft.net>

On Wed, 24 May 2017 14:22:29 -0700 Matthias Kaehlcke <mka@chromium.org> wrote:

> I'm not a kernel maintainer, so it's not my decision whether this
> warning should be silenced, my personal opinion is that it's benfits
> outweigh the inconveniences of dealing with half-false positives,
> generally caused by the heavy use of #ifdef by the kernel itself.

Please resend and include this info in the changelog.  Describe
instances where this warning has resulted in actual runtime or
developer-visible benefits.

Where possible an appropriate I suggest it is better to move the
offending function into a header file, rather than adding ifdefs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

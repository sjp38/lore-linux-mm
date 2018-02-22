Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id EE8E76B029D
	for <linux-mm@kvack.org>; Thu, 22 Feb 2018 04:27:10 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id o23so3262923wrc.9
        for <linux-mm@kvack.org>; Thu, 22 Feb 2018 01:27:10 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id t193si17423769wmt.149.2018.02.22.01.27.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 22 Feb 2018 01:27:09 -0800 (PST)
Date: Thu, 22 Feb 2018 10:26:54 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 00/13] Remove metag architecture
Message-ID: <20180222092654.GN25201@hirez.programming.kicks-ass.net>
References: <20180221233825.10024-1-jhogan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180221233825.10024-1-jhogan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Hogan <jhogan@kernel.org>
Cc: linux-metag@vger.kernel.org, linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>, Jonathan Corbet <corbet@lwn.net>, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>, Arnaldo Carvalho de Melo <acme@kernel.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Jiri Olsa <jolsa@redhat.com>, Namhyung Kim <namhyung@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Jason Cooper <jason@lakedaemon.net>, Marc Zyngier <marc.zyngier@arm.com>, Daniel Lezcano <daniel.lezcano@linaro.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Jiri Slaby <jslaby@suse.com>, Linus Walleij <linus.walleij@linaro.org>, Wim Van Sebroeck <wim@linux-watchdog.org>, Mauro Carvalho Chehab <mchehab@s-opensource.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, Wolfram Sang <wsa@the-dreams.de>, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-gpio@vger.kernel.org, linux-watchdog@vger.kernel.org, linux-media@vger.kernel.org, linux-i2c@vger.kernel.org

On Wed, Feb 21, 2018 at 11:38:12PM +0000, James Hogan wrote:
> So lets call it a day and drop the Meta architecture port from the
> kernel. RIP Meta.

So long, and thanks for all the fish!

Nice cleanup though, most welcome :-)

Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

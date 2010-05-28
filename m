Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id DEE78600385
	for <linux-mm@kvack.org>; Fri, 28 May 2010 05:33:22 -0400 (EDT)
Date: Fri, 28 May 2010 11:33:13 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH V3] x86, UV: BAU performance and error recovery
Message-ID: <20100528093313.GF24058@elte.hu>
References: <E1OGxWi-0000kI-Tc@eag09.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <E1OGxWi-0000kI-Tc@eag09.americas.sgi.com>
Sender: owner-linux-mm@kvack.org
To: Cliff Wickman <cpw@sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
List-ID: <linux-mm.kvack.org>


* Cliff Wickman <cpw@sgi.com> wrote:

> Ingo,
> This patch replaces the patch of the same name, from March 2010.
> You had queued it up for v2.6.35 on April 14.

FYI, those bits are upstream now:

  b8f7fb1: x86, UV: Improve BAU performance and error recovery

And will be in v2.6.35.

Please send your latest improvements against latest -tip.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

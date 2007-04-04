In-reply-to: <20070403144224.227434440@taijtu.programming.kicks-ass.net>
	(message from Peter Zijlstra on Tue, 03 Apr 2007 16:40:48 +0200)
Subject: Re: [PATCH 1/6] mm: scalable bdi statistics counters.
References: <20070403144047.073283598@taijtu.programming.kicks-ass.net> <20070403144224.227434440@taijtu.programming.kicks-ass.net>
Message-Id: <E1HZ1fn-0005oT-00@dorka.pomaz.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Wed, 04 Apr 2007 11:20:59 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: a.p.zijlstra@chello.nl
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com
List-ID: <linux-mm.kvack.org>

> Provide scalable per backing_dev_info statistics counters modeled on the ZVC
> code.

Why do we need global_bdi_stat()?  It should give approximately the
same numbers as global_page_state(), no?

Thanks,
Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

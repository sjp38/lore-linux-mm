Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id ACDD46B004A
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 04:27:06 -0400 (EDT)
Date: Tue, 13 Mar 2012 09:26:43 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 4/5] printk: use alloc_bootmem() instead of
 memblock_alloc().
Message-ID: <20120313082643.GA1888@elte.hu>
References: <1331617001-20906-1-git-send-email-apenwarr@gmail.com>
 <1331617001-20906-5-git-send-email-apenwarr@gmail.com>
 <CAE9FiQUakjaxE3fTm1w3SuuE-cAXAg2fePmEdwmjomAgp88Psg@mail.gmail.com>
 <CAHqTa-0b1DBDNYzDQ6UHHCivF9S-H3zvZWH0KZ21OQ8gQq6WYg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHqTa-0b1DBDNYzDQ6UHHCivF9S-H3zvZWH0KZ21OQ8gQq6WYg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Avery Pennarun <apenwarr@gmail.com>
Cc: Yinghai Lu <yinghai@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Josh Triplett <josh@joshtriplett.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, "David S. Miller" <davem@davemloft.net>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "Fabio M. Di Nitto" <fdinitto@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Olaf Hering <olaf@aepfle.de>, Paul Gortmaker <paul.gortmaker@windriver.com>, Tejun Heo <tj@kernel.org>, "H. Peter Anvin" <hpa@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org


* Avery Pennarun <apenwarr@gmail.com> wrote:

> Hmm.  x86 uses nobootmem.c, [...]

For new code, we use memblock_reserve(), memblock_alloc(), et al.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

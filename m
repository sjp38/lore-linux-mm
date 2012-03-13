Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 4E3A16B004A
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 02:41:11 -0400 (EDT)
Received: by vcbfk14 with SMTP id fk14so354335vcb.14
        for <linux-mm@kvack.org>; Mon, 12 Mar 2012 23:41:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAE9FiQUakjaxE3fTm1w3SuuE-cAXAg2fePmEdwmjomAgp88Psg@mail.gmail.com>
References: <1331617001-20906-1-git-send-email-apenwarr@gmail.com>
 <1331617001-20906-5-git-send-email-apenwarr@gmail.com> <CAE9FiQUakjaxE3fTm1w3SuuE-cAXAg2fePmEdwmjomAgp88Psg@mail.gmail.com>
From: Avery Pennarun <apenwarr@gmail.com>
Date: Tue, 13 Mar 2012 02:40:50 -0400
Message-ID: <CAHqTa-0b1DBDNYzDQ6UHHCivF9S-H3zvZWH0KZ21OQ8gQq6WYg@mail.gmail.com>
Subject: Re: [PATCH 4/5] printk: use alloc_bootmem() instead of memblock_alloc().
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yinghai Lu <yinghai@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Josh Triplett <josh@joshtriplett.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "David S. Miller" <davem@davemloft.net>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "Fabio M. Di Nitto" <fdinitto@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Olaf Hering <olaf@aepfle.de>, Paul Gortmaker <paul.gortmaker@windriver.com>, Tejun Heo <tj@kernel.org>, "H. Peter Anvin" <hpa@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

> that seems not right.
>
> for x86, setup_log_buf(1) is quite early called in setup_arch() before
> bootmem is there.
>
> bootmem should be killed after memblock is supported for arch that
> current support bootmem.

Hmm.  x86 uses nobootmem.c, which implements bootmem in terms of
memblock anyway.  It is definitely working at setup_log_buf() time (or
else it wouldn't be able to select a sensible buffer location).

I suppose you're saying that it wouldn't work for a hypothetical
architecture that *does* support bootmem and *also* supports
setup_log_buf(1).  Will there ever be such an architecture, or will
bootmem be retired first?

Thanks,

Avery

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

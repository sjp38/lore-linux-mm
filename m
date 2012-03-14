Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 19CE56B004A
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 22:23:40 -0400 (EDT)
Received: by vcbfk14 with SMTP id fk14so1921404vcb.14
        for <linux-mm@kvack.org>; Tue, 13 Mar 2012 19:23:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAE9FiQVkn_jHhdFfDg_zvJJuZci+kvOd6NSfL4aSc_GP=hiOWw@mail.gmail.com>
References: <1331617001-20906-1-git-send-email-apenwarr@gmail.com>
 <1331617001-20906-5-git-send-email-apenwarr@gmail.com> <CAE9FiQUakjaxE3fTm1w3SuuE-cAXAg2fePmEdwmjomAgp88Psg@mail.gmail.com>
 <CAHqTa-0b1DBDNYzDQ6UHHCivF9S-H3zvZWH0KZ21OQ8gQq6WYg@mail.gmail.com> <CAE9FiQVkn_jHhdFfDg_zvJJuZci+kvOd6NSfL4aSc_GP=hiOWw@mail.gmail.com>
From: Avery Pennarun <apenwarr@gmail.com>
Date: Tue, 13 Mar 2012 22:23:18 -0400
Message-ID: <CAHqTa-3p1sS1QvT3bg4UAo9G8Hq+-PJsSxBAz_P8pf+tdEOq4Q@mail.gmail.com>
Subject: Re: [PATCH 4/5] printk: use alloc_bootmem() instead of memblock_alloc().
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yinghai Lu <yinghai@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Josh Triplett <josh@joshtriplett.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "David S. Miller" <davem@davemloft.net>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "Fabio M. Di Nitto" <fdinitto@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Olaf Hering <olaf@aepfle.de>, Paul Gortmaker <paul.gortmaker@windriver.com>, Tejun Heo <tj@kernel.org>, "H. Peter Anvin" <hpa@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Mar 13, 2012 at 5:50 PM, Yinghai Lu <yinghai@kernel.org> wrote:
> Now you put back bootmem calling early, will cause confusion.
[...]
> we should use adding memblock_alloc calling instead... go backward...

Okay, I'm convinced.  I've updated my series so CONFIG_PRINTK_PERSIST
only works with HAVE_MEMBLOCK, and I've removed the patch to
unconditionally call bootmem in the existing non-PRINTK_PERSIST case.

(I'll upload the patches later once the other threads play out.)

Thanks for the quick feedback!

Avery

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

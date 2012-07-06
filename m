Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id AC47A6B0074
	for <linux-mm@kvack.org>; Fri,  6 Jul 2012 09:04:57 -0400 (EDT)
Received: by vbkv13 with SMTP id v13so7592482vbk.14
        for <linux-mm@kvack.org>; Fri, 06 Jul 2012 06:04:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120705165606.GA11296@dirshya.in.ibm.com>
References: <1340895238.28750.49.camel@twins>
	<CAJd=RBA+FPgB9iq07YG0Pd=tN65SGK1ifmj98tomBDbYeKOE-Q@mail.gmail.com>
	<20120629125517.GD32637@gmail.com>
	<4FEDDD0C.60609@redhat.com>
	<1340995260.28750.103.camel@twins>
	<4FEDF81C.1010401@redhat.com>
	<1340996224.28750.116.camel@twins>
	<1340996586.28750.122.camel@twins>
	<4FEDFFB5.3010401@redhat.com>
	<20120702165714.GA10952@dirshya.in.ibm.com>
	<20120705165606.GA11296@dirshya.in.ibm.com>
Date: Fri, 6 Jul 2012 21:04:56 +0800
Message-ID: <CAJd=RBDAtm_9TiFgsGC=DxFxtDRP7GLeA5xAs5e6_oYS1t46rg@mail.gmail.com>
Subject: Re: [PATCH 13/40] autonuma: CPU follow memory algorithm
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: svaidy@linux.vnet.ibm.com
Cc: Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, dlaor@redhat.com, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

Hi Vaidy,

On Fri, Jul 6, 2012 at 12:56 AM, Vaidyanathan Srinivasan
<svaidy@linux.vnet.ibm.com> wrote:
> --- a/mm/autonuma.c
> +++ b/mm/autonuma.c
> @@ -26,7 +26,7 @@ unsigned long autonuma_flags __read_mostly =
>  #ifdef CONFIG_AUTONUMA_DEFAULT_ENABLED
>         (1<<AUTONUMA_FLAG)|
>  #endif
> -       (1<<AUTONUMA_SCAN_PMD_FLAG);
> +       (0<<AUTONUMA_SCAN_PMD_FLAG);
>

Let X86 scan pmd by default, agree?

Good Weekend
Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

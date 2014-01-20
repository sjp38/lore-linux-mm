Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f53.google.com (mail-bk0-f53.google.com [209.85.214.53])
	by kanga.kvack.org (Postfix) with ESMTP id 4D5506B0035
	for <linux-mm@kvack.org>; Mon, 20 Jan 2014 08:18:26 -0500 (EST)
Received: by mail-bk0-f53.google.com with SMTP id my13so245322bkb.40
        for <linux-mm@kvack.org>; Mon, 20 Jan 2014 05:18:25 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id ou7si1582655bkb.128.2014.01.20.05.18.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Jan 2014 05:18:21 -0800 (PST)
Date: Mon, 20 Jan 2014 14:17:35 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v7 6/6] MCS Lock: add Kconfig entries to allow
 arch-specific hooks
Message-ID: <20140120131735.GD3694@twins.programming.kicks-ass.net>
References: <cover.1389890175.git.tim.c.chen@linux.intel.com>
 <1389917316.3138.16.camel@schen9-DESK>
 <20140120123030.GE31570@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140120123030.GE31570@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "Paul E.McKenney" <paulmck@linux.vnet.ibm.com>, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, linux-arch@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Mon, Jan 20, 2014 at 01:30:30PM +0100, Peter Zijlstra wrote:
> Then again, people seem to whinge if you don't keep these Kbuild files
> sorted, but manually sorting 29 files is just not something I like to
> do.

This seems to do it..

gawk '/^generic-y/ {
	i = 3;
	do {
		for (; i<=NF; i++) {
			if ($i == "\\") {
				getline;
				i=1;
				continue;
			}
			if ($i != "")
				hdr[$i] = $i;
		}
		break;
	} while (1);
	next;
}
// { print $0; }
END {
	n = asort(hdr);
	for (i=1; i<=n; i++)
		print "generic-y += " hdr[i];
}'


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 70ECB6B004F
	for <linux-mm@kvack.org>; Wed, 14 Jan 2009 10:30:51 -0500 (EST)
Received: by fg-out-1718.google.com with SMTP id 13so301431fge.4
        for <linux-mm@kvack.org>; Wed, 14 Jan 2009 07:30:48 -0800 (PST)
Message-ID: <84144f020901140730l747b4e06j41fb8a35daeaf6c8@mail.gmail.com>
Date: Wed, 14 Jan 2009 17:30:48 +0200
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [patch] SLQB slab allocator
In-Reply-To: <20090114152207.GD25401@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20090114090449.GE2942@wotan.suse.de>
	 <84144f020901140253s72995188vb35a79501c38eaa3@mail.gmail.com>
	 <20090114114707.GA24673@wotan.suse.de>
	 <84144f020901140544v56b856a4w80756b90f5b59f26@mail.gmail.com>
	 <20090114142200.GB25401@wotan.suse.de>
	 <84144f020901140645o68328e01ne0e10ace47555e19@mail.gmail.com>
	 <20090114150900.GC25401@wotan.suse.de>
	 <20090114152207.GD25401@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, Lin Ming <ming.m.lin@intel.com>, Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi Nick,

On Wed, Jan 14, 2009 at 5:22 PM, Nick Piggin <npiggin@suse.de> wrote:
> And... IIRC, the Intel guys did make a stink but it wasn't considered
> so important or worthwhile to fix for some reason? Anyway, the fact is
> that it hadn't been fixed in SLUB. Hmm, I guess it is a significant
> failure of SLUB that it hasn't managed to replace SLAB by this point.

Again, not speaking for Christoph, but *I* do consider the regression
to be important and I do want it to be fixed. I have asked for a test
case to reproduce the regression and/or oprofile reports but have yet
to receive them. I did fix one regression I saw with the fio benchmark
but unfortunately it wasn't the same regression the Intel guys are
hitting. I suppose we're in limbo now because the people who are
affected by the regression can simply turn on CONFIG_SLAB.

In any case, I do agree that the inability to replace SLAB with SLUB
is a failure on the latter. I'm just not totally convinced that it's
because the SLUB code is unfixable ;).

                                Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

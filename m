Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1D21A6B0038
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 21:58:48 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id z11so4598282pfk.23
        for <linux-mm@kvack.org>; Wed, 18 Oct 2017 18:58:48 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id m64si7674068pgm.509.2017.10.18.18.58.46
        for <linux-mm@kvack.org>;
        Wed, 18 Oct 2017 18:58:47 -0700 (PDT)
Date: Thu, 19 Oct 2017 10:58:36 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH 2/2] lockdep: Remove BROKEN flag of LOCKDEP_CROSSRELEASE
Message-ID: <20171019015836.GF32368@X58A-UD3R>
References: <1508318006-2090-1-git-send-email-byungchul.park@lge.com>
 <1508318006-2090-2-git-send-email-byungchul.park@lge.com>
 <20171018101208.jybvncw6odabdooj@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171018101208.jybvncw6odabdooj@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: peterz@infradead.org, tglx@linutronix.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@lge.com

On Wed, Oct 18, 2017 at 12:12:08PM +0200, Ingo Molnar wrote:
> 
> * Byungchul Park <byungchul.park@lge.com> wrote:
> 
> > Now the performance regression was fixed, re-enable LOCKDEP_CROSSRELEASE
> > and LOCKDEP_COMPLETIONS.
> 
> Please write out CONFIG_ variables, i.e. CONFIG_LOCKDEP_CROSSRELEASE, etc. - to 
> make it all more apparent to the reader that it's all Kconfig space changes.

Yes, I will. Thank you.

> 
> Thanks,
> 
> 	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

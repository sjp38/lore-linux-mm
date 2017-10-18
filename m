Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 170D96B0033
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 06:12:12 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id k15so2235240wrc.1
        for <linux-mm@kvack.org>; Wed, 18 Oct 2017 03:12:12 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id d63sor2894082wmf.27.2017.10.18.03.12.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 18 Oct 2017 03:12:11 -0700 (PDT)
Date: Wed, 18 Oct 2017 12:12:08 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 2/2] lockdep: Remove BROKEN flag of LOCKDEP_CROSSRELEASE
Message-ID: <20171018101208.jybvncw6odabdooj@gmail.com>
References: <1508318006-2090-1-git-send-email-byungchul.park@lge.com>
 <1508318006-2090-2-git-send-email-byungchul.park@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1508318006-2090-2-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: peterz@infradead.org, tglx@linutronix.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@lge.com


* Byungchul Park <byungchul.park@lge.com> wrote:

> Now the performance regression was fixed, re-enable LOCKDEP_CROSSRELEASE
> and LOCKDEP_COMPLETIONS.

Please write out CONFIG_ variables, i.e. CONFIG_LOCKDEP_CROSSRELEASE, etc. - to 
make it all more apparent to the reader that it's all Kconfig space changes.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

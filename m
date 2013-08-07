Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 4C6506B0032
	for <linux-mm@kvack.org>; Wed,  7 Aug 2013 16:45:32 -0400 (EDT)
Received: by mail-qa0-f48.google.com with SMTP id o19so1324685qap.14
        for <linux-mm@kvack.org>; Wed, 07 Aug 2013 13:45:31 -0700 (PDT)
Date: Wed, 7 Aug 2013 16:45:27 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v2] mm: make lru_add_drain_all() selective
Message-ID: <20130807204527.GB28039@mtj.dyndns.org>
References: <201308071458.r77EwuJV013106@farm-0012.internal.tilera.com>
 <201308071551.r77FpWTf022475@farm-0012.internal.tilera.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201308071551.r77FpWTf022475@farm-0012.internal.tilera.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Metcalf <cmetcalf@tilera.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Frederic Weisbecker <fweisbec@gmail.com>

On Tue, Aug 06, 2013 at 04:22:39PM -0400, Chris Metcalf wrote:
> This change makes lru_add_drain_all() only selectively interrupt
> the cpus that have per-cpu free pages that can be drained.
> 
> This is important in nohz mode where calling mlockall(), for
> example, otherwise will interrupt every core unnecessarily.

Can you please split off workqueue part into a separate patch with
proper description?  I don't mind the change eventually going through
-mm but it's nasty to bury workqueue API update with another change
without explanation or justification.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

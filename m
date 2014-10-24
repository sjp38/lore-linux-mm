Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 1E2646B0069
	for <linux-mm@kvack.org>; Fri, 24 Oct 2014 08:08:26 -0400 (EDT)
Received: by mail-wi0-f178.google.com with SMTP id q5so1062207wiv.5
        for <linux-mm@kvack.org>; Fri, 24 Oct 2014 05:08:25 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id uw9si5115780wjc.37.2014.10.24.05.08.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 24 Oct 2014 05:08:24 -0700 (PDT)
Date: Fri, 24 Oct 2014 14:08:11 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v9 05/12] x86, mpx: on-demand kernel allocation of bounds
 tables
In-Reply-To: <1413088915-13428-6-git-send-email-qiaowei.ren@intel.com>
Message-ID: <alpine.DEB.2.11.1410241257300.5308@nanos>
References: <1413088915-13428-1-git-send-email-qiaowei.ren@intel.com> <1413088915-13428-6-git-send-email-qiaowei.ren@intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qiaowei Ren <qiaowei.ren@intel.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, Dave Hansen <dave.hansen@intel.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org

On Sun, 12 Oct 2014, Qiaowei Ren wrote:
> +	/*
> +	 * Go poke the address of the new bounds table in to the
> +	 * bounds directory entry out in userspace memory.  Note:
> +	 * we may race with another CPU instantiating the same table.
> +	 * In that case the cmpxchg will see an unexpected
> +	 * 'actual_old_val'.
> +	 */
> +	ret = user_atomic_cmpxchg_inatomic(&actual_old_val, bd_entry,
> +					   expected_old_val, bt_addr);

This is fully preemptible non-atomic context, right?

So this wants a proper comment, why using
user_atomic_cmpxchg_inatomic() is the right thing to do here.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

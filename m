Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id DA8986B016C
	for <linux-mm@kvack.org>; Mon, 22 Aug 2011 06:17:39 -0400 (EDT)
Received: by bkbzt4 with SMTP id zt4so4919093bkb.14
        for <linux-mm@kvack.org>; Mon, 22 Aug 2011 03:17:36 -0700 (PDT)
Date: Mon, 22 Aug 2011 14:17:30 +0400
From: Vasiliy Kulikov <segoon@openwall.com>
Subject: Re: [RFC] x86, mm: start mmap allocation for libs from low
 addresses
Message-ID: <20110822101730.GA3346@albatros>
References: <20110812102954.GA3496@albatros>
 <ccea406f-62be-4344-8036-a1b092937fe9@email.android.com>
 <20110816090540.GA7857@albatros>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110816090540.GA7857@albatros>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, kernel-hardening@lists.openwall.com, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Ingo, Peter, Thomas,

On Tue, Aug 16, 2011 at 13:05 +0400, Vasiliy Kulikov wrote:
> As the changes are not intrusive, we'd want to see this feature in the
> upstream kernel.  If you know why the patch cannot be a part of the
> upstream kernel - please tell me, I'll try to address the issues.

Any comments on the RFC?  Otherwise, may I resend it as a PATCH for
inclusion?

Thanks!

-- 
Vasiliy Kulikov
http://www.openwall.com - bringing security into open computing environments

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

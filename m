Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 4ACE06B006A
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 12:31:10 -0500 (EST)
Subject: Re: [PATCH v3 04/12] Add "handle page fault" PV helper.
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <1262700774-1808-5-git-send-email-gleb@redhat.com>
References: <1262700774-1808-1-git-send-email-gleb@redhat.com>
	 <1262700774-1808-5-git-send-email-gleb@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 14 Jan 2010 18:31:07 +0100
Message-ID: <1263490267.4244.340.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Tue, 2010-01-05 at 16:12 +0200, Gleb Natapov wrote:
> Allow paravirtualized guest to do special handling for some page faults.
> 
> The patch adds one 'if' to do_page_fault() function. The call is patched
> out when running on physical HW. I ran kernbech on the kernel with and
> without that additional 'if' and result were rawly the same:

So why not program a different handler address for the #PF/#GP faults
and avoid the if all together?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

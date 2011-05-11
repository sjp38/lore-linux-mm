Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 718EB6B0012
	for <linux-mm@kvack.org>; Wed, 11 May 2011 13:39:23 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 1/3] comm: Introduce comm_lock seqlock to protect task->comm access
References: <1305073386-4810-1-git-send-email-john.stultz@linaro.org>
	<1305073386-4810-2-git-send-email-john.stultz@linaro.org>
Date: Wed, 11 May 2011 10:39:01 -0700
In-Reply-To: <1305073386-4810-2-git-send-email-john.stultz@linaro.org> (John
	Stultz's message of "Tue, 10 May 2011 17:23:04 -0700")
Message-ID: <m2oc39i1ca.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Ted Ts'o <tytso@mit.edu>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

John Stultz <john.stultz@linaro.org> writes:
>
> The next step is to go through and convert all comm accesses to
> use get_task_comm(). This is substantial, but can be done bit by
> bit, reducing the race windows with each patch.

... and after that rename the field.

-Andi

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 944096B0062
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 10:24:42 -0500 (EST)
Message-ID: <4AEEF9AE.1090904@kernel.org>
Date: Tue, 03 Nov 2009 00:24:30 +0900
From: Tejun Heo <tj@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH 1/1] MM: slqb, fix per_cpu access
References: <4AEE5EA2.6010905@kernel.org> <1257151763-11507-1-git-send-email-jirislaby@gmail.com>
In-Reply-To: <1257151763-11507-1-git-send-email-jirislaby@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Jiri Slaby <jirislaby@gmail.com>
Cc: npiggin@suse.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

2009e?? 11i?? 02i? 1/4  17:49, Jiri Slaby wrote:
> We cannot use the same local variable name as the declared per_cpu
> variable since commit "percpu: remove per_cpu__ prefix."
> 
> Otherwise we would see crashes like:
> general protection fault: 0000 [#1] SMP
> last sysfs file:
> CPU 1
> Modules linked in:
> Pid: 1, comm: swapper Tainted: G        W  2.6.32-rc5-mm1_64 #860
> RIP: 0010:[<ffffffff8142ff94>]  [<ffffffff8142ff94>] start_cpu_timer+0x2b/0x87
> ...
> 
> Use slqb_ prefix for the global variable so that we don't collide
> even with the rest of the kernel (s390 and alpha need this).
> 
> Signed-off-by: Jiri Slaby <jirislaby@gmail.com>
> Cc: Nick Piggin <npiggin@suse.de>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: Rusty Russell <rusty@rustcorp.com.au>
> Cc: Christoph Lameter <cl@linux-foundation.org>

Acked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

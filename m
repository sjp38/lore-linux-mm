Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 9D0EC6B0062
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 04:20:57 -0400 (EDT)
Received: by qaea16 with SMTP id a16so1524472qae.3
        for <linux-mm@kvack.org>; Mon, 18 Jun 2012 01:20:56 -0700 (PDT)
Message-ID: <4FDEE4E6.6030205@gmail.com>
Date: Mon, 18 Jun 2012 04:20:54 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5] slab/mempolicy: always use local policy from interrupt
 context
References: <1338438844-5022-1-git-send-email-andi@firstfloor.org> <1339234803-21106-1-git-send-email-tdmackey@twitter.com>
In-Reply-To: <1339234803-21106-1-git-send-email-tdmackey@twitter.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Mackey <tdmackey@twitter.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, rientjes@google.com, Andi Kleen <ak@linux.intel.com>, penberg@kernel.org, cl@linux.com, kosaki.motohiro@gmail.com

(6/9/12 5:40 AM), David Mackey wrote:
> From: Andi Kleen<ak@linux.intel.com>
> 
> From: Andi Kleen<ak@linux.intel.com>
> 
> slab_node() could access current->mempolicy from interrupt context.
> However there's a race condition during exit where the mempolicy
> is first freed and then the pointer zeroed.
> 
> Using this from interrupts seems bogus anyways. The interrupt
> will interrupt a random process and therefore get a random
> mempolicy. Many times, this will be idle's, which noone can change.
> 
> Just disable this here and always use local for slab
> from interrupts. I also cleaned up the callers of slab_node a bit
> which always passed the same argument.
> 
> I believe the original mempolicy code did that in fact,
> so it's likely a regression.
> 
> v2: send version with correct logic
> v3: simplify. fix typo.
> Reported-by: Arun Sharma<asharma@fb.com>
> Cc: penberg@kernel.org
> Cc: cl@linux.com
> Signed-off-by: Andi Kleen<ak@linux.intel.com>
> [tdmackey@twitter.com: Rework control flow based on feedback from
> cl@linux.com, fix logic, and cleanup current task_struct reference]
> Signed-off-by: David Mackey<tdmackey@twitter.com>

Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

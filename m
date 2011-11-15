Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 8AE3F6B002D
	for <linux-mm@kvack.org>; Tue, 15 Nov 2011 09:49:51 -0500 (EST)
Received: by pzk1 with SMTP id 1so14021036pzk.6
        for <linux-mm@kvack.org>; Tue, 15 Nov 2011 06:49:48 -0800 (PST)
Date: Tue, 15 Nov 2011 06:49:43 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCCH percpu: add cpunum param in per_cpu_ptr_to_phys
Message-ID: <20111115144943.GJ30922@google.com>
References: <20111115083646.GA21468@darkstar.nay.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111115083646.GA21468@darkstar.nay.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Young <dyoung@redhat.com>
Cc: gregkh@suse.de, cl@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Nov 15, 2011 at 04:36:46PM +0800, Dave Young wrote:
> per_cpu_ptr_to_phys iterate all cpu to get the phy addr
> let's leave the caller to pass the cpu number to it.
> 
> Actually in the only one user show_crash_notes,
> cpunum is provided already before calling this. 
> 
> Signed-off-by: Dave Young <dyoung@redhat.com>

Does this matter?  If it's not a performance critical path, I'd rather
keep the generic funtionality.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

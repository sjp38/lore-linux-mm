Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5F2808D003A
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 10:01:12 -0400 (EDT)
Received: by pxi10 with SMTP id 10so155454pxi.8
        for <linux-mm@kvack.org>; Tue, 15 Mar 2011 07:01:08 -0700 (PDT)
Message-ID: <4D7F7121.5040009@librato.com>
Date: Tue, 15 Mar 2011 10:01:05 -0400
From: Mike Heffner <mike@librato.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6 6/9] memcg: add cgroupfs interface to memcg dirty limits
References: <1299869011-26152-1-git-send-email-gthelen@google.com> <1299869011-26152-7-git-send-email-gthelen@google.com>
In-Reply-To: <1299869011-26152-7-git-send-email-gthelen@google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Chad Talbott <ctalbott@google.com>, Justin TerAvest <teravest@google.com>, Andrea Righi <arighi@develer.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-kernel@vger.kernel.org, Vivek Goyal <vgoyal@redhat.com>, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Wu Fengguang <fengguang.wu@intel.com>, Balbir Singh <balbir@linux.vnet.ibm.com>

On 03/11/2011 01:43 PM, Greg Thelen wrote:
> Add cgroupfs interface to memcg dirty page limits:
>    Direct write-out is controlled with:
>    - memory.dirty_ratio
>    - memory.dirty_limit_in_bytes
>
>    Background write-out is controlled with:
>    - memory.dirty_background_ratio
>    - memory.dirty_background_limit_bytes


What's the overlap, if any, with the current memory limits controlled by 
`memory.limit_in_bytes` and the above `memory.dirty_limit_in_bytes`? If 
I want to fairly balance memory between two cgroups be one a dirty page 
antagonist (dd) and the other an anonymous page (memcache), do I just 
set `memory.limit_in_bytes`? Does this patch simply provide a more 
granular level of control of the dirty limits?


Thanks,

Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

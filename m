Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f46.google.com (mail-bk0-f46.google.com [209.85.214.46])
	by kanga.kvack.org (Postfix) with ESMTP id 70FDD6B0035
	for <linux-mm@kvack.org>; Sun, 26 Jan 2014 10:27:35 -0500 (EST)
Received: by mail-bk0-f46.google.com with SMTP id r7so2285314bkg.5
        for <linux-mm@kvack.org>; Sun, 26 Jan 2014 07:27:34 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id on6si10793795bkb.55.2014.01.26.07.27.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 26 Jan 2014 07:27:34 -0800 (PST)
Date: Sun, 26 Jan 2014 10:27:28 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch] mm, oom: base root bonus on current usage
Message-ID: <20140126152728.GY6963@cmpxchg.org>
References: <20140115234308.GB4407@cmpxchg.org>
 <alpine.DEB.2.02.1401151614480.15665@chino.kir.corp.google.com>
 <20140116070709.GM6963@cmpxchg.org>
 <alpine.DEB.2.02.1401212050340.8512@chino.kir.corp.google.com>
 <20140124040531.GF4407@cmpxchg.org>
 <alpine.DEB.2.02.1401251942510.3140@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1401251942510.3140@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, Jan 25, 2014 at 07:48:32PM -0800, David Rientjes wrote:
> A 3% of system memory bonus is sometimes too excessive in comparison to 
> other processes and can yield poor results when all processes on the 
> system are root and none of them use over 3% of memory.
> 
> Replace the 3% of system memory bonus with a 3% of current memory usage 
> bonus.
> 
> Reported-by: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: David Rientjes <rientjes@google.com>

Looks good, thanks a lot!

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9B9E66B0005
	for <linux-mm@kvack.org>; Tue, 29 May 2018 06:22:20 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id w7-v6so8908686pfd.9
        for <linux-mm@kvack.org>; Tue, 29 May 2018 03:22:20 -0700 (PDT)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id j6-v6si25996337pgc.509.2018.05.29.03.22.18
        for <linux-mm@kvack.org>;
        Tue, 29 May 2018 03:22:19 -0700 (PDT)
Date: Tue, 29 May 2018 20:22:15 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v2] doc: document scope NOFS, NOIO APIs
Message-ID: <20180529102215.GL23861@dastard>
References: <20180524114341.1101-1-mhocko@kernel.org>
 <20180529082644.26192-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180529082644.26192-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Jonathan Corbet <corbet@lwn.net>, Randy Dunlap <rdunlap@infradead.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>

On Tue, May 29, 2018 at 10:26:44AM +0200, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> Although the api is documented in the source code Ted has pointed out
> that there is no mention in the core-api Documentation and there are
> people looking there to find answers how to use a specific API.
> 
> Changes since v1
> - add kerneldoc for the api - suggested by Johnatan
> - review feedback from Dave and Johnatan
> - feedback from Dave about more general critical context rather than
>   locking
> - feedback from Mike
> - typo fixed - Randy, Dave
> 
> Requested-by: "Theodore Y. Ts'o" <tytso@mit.edu>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

We could bikeshed forever about the exact wording, but it covers
everything I think needs to be documented.

Reviewed-by: Dave Chinner <dchinner@redhat.com>

-- 
Dave Chinner
david@fromorbit.com

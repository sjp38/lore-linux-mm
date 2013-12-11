Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f173.google.com (mail-ie0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id DA07F6B0035
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 20:35:13 -0500 (EST)
Received: by mail-ie0-f173.google.com with SMTP id to1so10044798ieb.32
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 17:35:13 -0800 (PST)
Received: from smtprelay.hostedemail.com (smtprelay0091.hostedemail.com. [216.40.44.91])
        by mx.google.com with ESMTP id t5si3022510igw.57.2013.12.10.17.35.12
        for <linux-mm@kvack.org>;
        Tue, 10 Dec 2013 17:35:12 -0800 (PST)
Message-ID: <1386725708.8168.25.camel@joe-AO722>
Subject: Re: [patch] checkpatch: add warning of future __GFP_NOFAIL use
From: Joe Perches <joe@perches.com>
Date: Tue, 10 Dec 2013 17:35:08 -0800
In-Reply-To: <alpine.DEB.2.02.1312101624330.22701@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1312091355360.11026@chino.kir.corp.google.com>
	 <20131209152202.df3d4051d7dc61ada7c420a9@linux-foundation.org>
	 <alpine.DEB.2.02.1312101504120.22701@chino.kir.corp.google.com>
	 <alpine.DEB.2.02.1312101618530.22701@chino.kir.corp.google.com>
	 <alpine.DEB.2.02.1312101624330.22701@chino.kir.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andy Whitcroft <apw@canonical.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 2013-12-10 at 16:26 -0800, David Rientjes wrote:
> gfp.h and page_alloc.c already specify that __GFP_NOFAIL is deprecated and 
> no new users should be added.
> 
> Add a warning to checkpatch to catch this.

Fine by me.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

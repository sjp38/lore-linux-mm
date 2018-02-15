Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id D4B756B0003
	for <linux-mm@kvack.org>; Thu, 15 Feb 2018 09:48:09 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id i143so306283wmf.2
        for <linux-mm@kvack.org>; Thu, 15 Feb 2018 06:48:09 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t129si1065344wme.138.2018.02.15.06.48.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 15 Feb 2018 06:48:08 -0800 (PST)
Date: Thu, 15 Feb 2018 15:48:07 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [LSF/MM ATTEND] memory allocation scope
Message-ID: <20180215144807.GH7275@dhcp22.suse.cz>
References: <8b9d4170-bc71-3338-6b46-22130f828adb@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8b9d4170-bc71-3338-6b46-22130f828adb@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Goldwyn Rodrigues <rgoldwyn@suse.de>
Cc: lsf-pc@lists.linux-foundation.org, Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org

On Wed 14-02-18 16:51:53, Goldwyn Rodrigues wrote:
> 
> Discussion with the memory folks towards scope based allocation
> I am working on converting some of the GFP_NOFS memory allocation calls
> to new scope API [1]. While other allocation types (noio, nofs,
> noreclaim) are covered. Are there plans for identifying scope of
> GFP_ATOMIC allocations? This should cover most (if not all) of the
> allocation scope.

There was no explicit request for that but I can see how some users
might want it. I would have to double check but maybe this would allow
vmalloc(GFP_ATOMIC). There were some users but most of them could have
been changed in some way so the motivation is not very large.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

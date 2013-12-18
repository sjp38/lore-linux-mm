Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f46.google.com (mail-ee0-f46.google.com [74.125.83.46])
	by kanga.kvack.org (Postfix) with ESMTP id 7A1346B0035
	for <linux-mm@kvack.org>; Wed, 18 Dec 2013 11:09:40 -0500 (EST)
Received: by mail-ee0-f46.google.com with SMTP id d49so3635659eek.19
        for <linux-mm@kvack.org>; Wed, 18 Dec 2013 08:09:39 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w6si618496eeg.153.2013.12.18.08.09.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 18 Dec 2013 08:09:39 -0800 (PST)
Date: Wed, 18 Dec 2013 16:09:36 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC PATCH 0/6] Configurable fair allocation zone policy v3
Message-ID: <20131218160936.GX11295@suse.de>
References: <1387298904-8824-1-git-send-email-mgorman@suse.de>
 <20131217200210.GG21724@cmpxchg.org>
 <20131218061750.GK21724@cmpxchg.org>
 <20131218150038.GP11295@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20131218150038.GP11295@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Dec 18, 2013 at 03:00:38PM +0000, Mel Gorman wrote:
> 
> For what it's worth, this is what I've currently kicked off testes for
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/mel/linux-balancenuma.git mm-pgalloc-interleave-zones-v4r12
> 

Pushed a dirty tree by accident. Now mm-pgalloc-interleave-zones-v4r13

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 941FE6B0003
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 11:10:12 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id r21-v6so1985074edp.23
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 08:10:12 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p34-v6si1886236edp.402.2018.07.18.08.10.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jul 2018 08:10:11 -0700 (PDT)
Date: Wed, 18 Jul 2018 17:10:09 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/page_alloc: Deprecate kernelcore=nn and movable_core=
Message-ID: <20180718151009.GJ7193@dhcp22.suse.cz>
References: <20180717131837.18411-1-bhe@redhat.com>
 <alpine.DEB.2.21.1807171344320.12251@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1807171344320.12251@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Baoquan He <bhe@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, corbet@lwn.net, linux-doc@vger.kernel.org

On Tue 17-07-18 13:46:43, David Rientjes wrote:
> On Tue, 17 Jul 2018, Baoquan He wrote:
> 
> > We can still use 'kernelcore=mirror' or 'movable_node' for the usage
> > of hotplug and movable zone. If somebody shows up with a valid usecase
> > we can reconsider.
> > 
> 
> We actively use kernelcore=n%, I had recently added support for the option 
> in the first place in 4.17.  It's certainly not deprecated.
> 
> commit a5c6d6509342785bef53bf9508e1842b303f1878
> Author: David Rientjes <rientjes@google.com>
> Date:   Thu Apr 5 16:23:09 2018 -0700
> 
>     mm, page_alloc: extend kernelcore and movablecore for percent

What kind of functionality do you need to not depend on this knob?
I mean it is a gross hack and you are basically working around
fragmentation issues. ZONE_MOVABLE doesn't seem to be a long term
solution here IMHO.
-- 
Michal Hocko
SUSE Labs

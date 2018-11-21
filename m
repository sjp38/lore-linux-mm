Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 71B146B26E2
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 12:58:12 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id v4so3251059edm.18
        for <linux-mm@kvack.org>; Wed, 21 Nov 2018 09:58:12 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d12si5374377edh.283.2018.11.21.09.58.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Nov 2018 09:58:10 -0800 (PST)
Date: Wed, 21 Nov 2018 18:58:09 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 1/3] mm, proc: be more verbose about unstable VMA
 flags in /proc/<pid>/smaps
Message-ID: <20181121175809.GT12932@dhcp22.suse.cz>
References: <20181120103515.25280-1-mhocko@kernel.org>
 <20181120103515.25280-2-mhocko@kernel.org>
 <20181121175427.GB5704@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181121175427.GB5704@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: linux-api@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Alexey Dobriyan <adobriyan@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Dan Williams <dan.j.williams@intel.com>, David Rientjes <rientjes@google.com>

On Wed 21-11-18 18:54:28, Mike Rapoport wrote:
> On Tue, Nov 20, 2018 at 11:35:13AM +0100, Michal Hocko wrote:
[...]
> > diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
> > index 12a5e6e693b6..b1fda309f067 100644
> > --- a/Documentation/filesystems/proc.txt
> > +++ b/Documentation/filesystems/proc.txt
> > @@ -496,7 +496,9 @@ flags associated with the particular virtual memory area in two letter encoded
> > 
> >  Note that there is no guarantee that every flag and associated mnemonic will
> >  be present in all further kernel releases. Things get changed, the flags may
> > -be vanished or the reverse -- new added.
> > +be vanished or the reverse -- new added. Interpretatation of their meaning
> > +might change in future as well. So each consumnent of these flags have to
> 
>                                            consumer?                 has

fixed. Thanks!

-- 
Michal Hocko
SUSE Labs

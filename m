Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 879BA6B0038
	for <linux-mm@kvack.org>; Fri,  3 Nov 2017 05:00:02 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id n8so885406wmg.4
        for <linux-mm@kvack.org>; Fri, 03 Nov 2017 02:00:02 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k2si4554888edi.308.2017.11.03.02.00.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 03 Nov 2017 02:00:01 -0700 (PDT)
Date: Fri, 3 Nov 2017 09:59:58 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v1 1/1] mm: buddy page accessed before initialized
Message-ID: <20171103085958.pewhlyvkr5oa2fgf@dhcp22.suse.cz>
References: <20171031155002.21691-1-pasha.tatashin@oracle.com>
 <20171031155002.21691-2-pasha.tatashin@oracle.com>
 <20171102133235.2vfmmut6w4of2y3j@dhcp22.suse.cz>
 <a9b637b0-2ff0-80e8-76a7-801c5c0820a8@oracle.com>
 <20171102135423.voxnzk2qkvfgu5l3@dhcp22.suse.cz>
 <94ab73c0-cd18-f58f-eebe-d585fde319e4@oracle.com>
 <20171102140830.z5uqmrurb6ohfvlj@dhcp22.suse.cz>
 <813ed7e3-9347-a1f2-1629-464d920f877d@oracle.com>
 <20171102142742.gpkif3hgnd62nyol@dhcp22.suse.cz>
 <8b3bb799-818b-b6b6-7c6b-9eee709decb7@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8b3bb799-818b-b6b6-7c6b-9eee709decb7@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, akpm@linux-foundation.org, mgorman@techsingularity.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 02-11-17 12:10:39, Pavel Tatashin wrote:
> > > 
> > > Yes, but as I said, unfortunately memset(1) with CONFIG_VM_DEBUG does not
> > > catch this case. So, when CONFIG_VM_DEBUG is enabled kexec reboots without
> > > issues.
> > 
> > Can we make the init pattern to catch this?
> 
> Unfortunately, that is not easy: memset() gives us only one byte to play
> with, and if we use something else that will make CONFIG_VM_DEBUG
> unacceptably slow.

Why cannot we do something similar to the optimized struct page
initialization and write 8B at the time and fill up the size unaligned
chunk in 1B?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

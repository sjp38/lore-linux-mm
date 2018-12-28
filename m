Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 903BF8E0001
	for <linux-mm@kvack.org>; Fri, 28 Dec 2018 07:20:00 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id c53so25687396edc.9
        for <linux-mm@kvack.org>; Fri, 28 Dec 2018 04:20:00 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b20si4683797edr.54.2018.12.28.04.19.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Dec 2018 04:19:59 -0800 (PST)
Date: Fri, 28 Dec 2018 13:19:56 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: + mm-thp-always-specify-disabled-vmas-as-nh-in-smaps.patch added
 to -mm tree
Message-ID: <20181228121956.GT16738@dhcp22.suse.cz>
References: <20181221151256.GA6410@dhcp22.suse.cz>
 <20181221140301.0e87b79b923ceb6d0f683749@linux-foundation.org>
 <alpine.DEB.2.21.1812211419320.219499@chino.kir.corp.google.com>
 <20181224080426.GC9063@dhcp22.suse.cz>
 <alpine.DEB.2.21.1812240058060.114867@chino.kir.corp.google.com>
 <20181224091731.GB16738@dhcp22.suse.cz>
 <20181227111114.5tvvkddyp7cytzeb@kshutemo-mobl1>
 <20181227213100.aeee730c1f9ec5cb11de39a3@linux-foundation.org>
 <20181228081847.GP16738@dhcp22.suse.cz>
 <00ec4644-70c2-4bd1-ec3f-b994fa0669e8@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <00ec4644-70c2-4bd1-ec3f-b994fa0669e8@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, kirill.shutemov@linux.intel.com, adobriyan@gmail.com, Linux API <linux-api@vger.kernel.org>, Andrei Vagin <avagin@gmail.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Pavel Emelyanov <xemul@virtuozzo.com>, Linux-MM layout <linux-mm@kvack.org>

On Fri 28-12-18 11:54:17, Vlastimil Babka wrote:
[...]
> Michal has a patch [2] that reports the prctl() status separately, but
> that doesn't help David's existing userspace.

This is something that is not really clear to me. I have asked several
times already and never got any reply IIRC. The code is obviously very
specific for their setup. Why is it not viable to update the code
in question now that a long term, easily backportable and properly
supported API exists?

I do understand that a lack of such an API pushes people to use whatever
sounds usable (even when undocumented) but we do have that interface
now. So what is the roadblock?

Or do we really want to make vma flags properly supported and carved in
stone interface?
-- 
Michal Hocko
SUSE Labs

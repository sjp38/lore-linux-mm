Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3FD906B0005
	for <linux-mm@kvack.org>; Wed, 17 Oct 2018 15:59:22 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id r134-v6so15978168pgr.19
        for <linux-mm@kvack.org>; Wed, 17 Oct 2018 12:59:22 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 34-v6sor8584378pgl.29.2018.10.17.12.59.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Oct 2018 12:59:21 -0700 (PDT)
Date: Wed, 17 Oct 2018 12:59:18 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC PATCH] mm, proc: report PR_SET_THP_DISABLE in proc
In-Reply-To: <20181017070531.GC18839@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.21.1810171256330.60837@chino.kir.corp.google.com>
References: <alpine.DEB.2.21.1810031547150.202532@chino.kir.corp.google.com> <20181004055842.GA22173@dhcp22.suse.cz> <alpine.DEB.2.21.1810040209130.113459@chino.kir.corp.google.com> <20181004094637.GG22173@dhcp22.suse.cz> <alpine.DEB.2.21.1810041130380.12951@chino.kir.corp.google.com>
 <20181009083326.GG8528@dhcp22.suse.cz> <20181015150325.GN18839@dhcp22.suse.cz> <alpine.DEB.2.21.1810151519250.247641@chino.kir.corp.google.com> <20181016104855.GQ18839@dhcp22.suse.cz> <alpine.DEB.2.21.1810161416540.83080@chino.kir.corp.google.com>
 <20181017070531.GC18839@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Alexey Dobriyan <adobriyan@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org

On Wed, 17 Oct 2018, Michal Hocko wrote:

> Do you know of any other userspace except your usecase? Is there
> anything fundamental that would prevent a proper API adoption for you?
> 

Yes, it would require us to go back in time and build patched binaries. 

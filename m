Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4966A6B02EE
	for <linux-mm@kvack.org>; Wed, 17 May 2017 11:27:57 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id l78so10451220iod.4
        for <linux-mm@kvack.org>; Wed, 17 May 2017 08:27:57 -0700 (PDT)
Received: from resqmta-ch2-04v.sys.comcast.net (resqmta-ch2-04v.sys.comcast.net. [2001:558:fe21:29:69:252:207:36])
        by mx.google.com with ESMTPS id z69si2489369iod.184.2017.05.17.08.27.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 May 2017 08:27:56 -0700 (PDT)
Date: Wed, 17 May 2017 10:27:55 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC 1/6] mm, page_alloc: fix more premature OOM due to race
 with cpuset update
In-Reply-To: <20170517145645.GO18247@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.20.1705171026590.9487@east.gentwo.org>
References: <a86ae57a-3efc-6ae5-ddf0-fd64c53c20fa@suse.cz> <alpine.DEB.2.20.1704121617040.28335@east.gentwo.org> <cf9628e9-20ed-68b0-6cbd-48af5133138c@suse.cz> <alpine.DEB.2.20.1704141526260.17435@east.gentwo.org> <fda99ddc-94f5-456e-6560-d4991da452a6@suse.cz>
 <alpine.DEB.2.20.1704301628460.21533@east.gentwo.org> <20170517092042.GH18247@dhcp22.suse.cz> <alpine.DEB.2.20.1705170855430.7925@east.gentwo.org> <20170517140501.GM18247@dhcp22.suse.cz> <alpine.DEB.2.20.1705170943090.8714@east.gentwo.org>
 <20170517145645.GO18247@dhcp22.suse.cz>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Li Zefan <lizefan@huawei.com>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-api@vger.kernel.org

On Wed, 17 May 2017, Michal Hocko wrote:

> > The race is where? If you expand the node set during the move of the
> > application then you are safe in terms of the legacy apps that did not
> > include static bindings.
>
> I am pretty sure it is describe in those changelogs and I won't repeat
> it here.

I cannot figure out what you are referring to. There are numerous
patches and discussions about OOM scenarios in this context.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

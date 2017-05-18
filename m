Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id E24BE831F4
	for <linux-mm@kvack.org>; Thu, 18 May 2017 12:57:59 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id s131so30605641itd.6
        for <linux-mm@kvack.org>; Thu, 18 May 2017 09:57:59 -0700 (PDT)
Received: from resqmta-ch2-12v.sys.comcast.net (resqmta-ch2-12v.sys.comcast.net. [2001:558:fe21:29:69:252:207:44])
        by mx.google.com with ESMTPS id a1si20201292ita.86.2017.05.18.09.57.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 May 2017 09:57:59 -0700 (PDT)
Date: Thu, 18 May 2017 11:57:55 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC 1/6] mm, page_alloc: fix more premature OOM due to race
 with cpuset update
In-Reply-To: <20170518090846.GD25462@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.20.1705181154450.27641@east.gentwo.org>
References: <cf9628e9-20ed-68b0-6cbd-48af5133138c@suse.cz> <alpine.DEB.2.20.1704141526260.17435@east.gentwo.org> <fda99ddc-94f5-456e-6560-d4991da452a6@suse.cz> <alpine.DEB.2.20.1704301628460.21533@east.gentwo.org> <20170517092042.GH18247@dhcp22.suse.cz>
 <alpine.DEB.2.20.1705170855430.7925@east.gentwo.org> <20170517140501.GM18247@dhcp22.suse.cz> <alpine.DEB.2.20.1705170943090.8714@east.gentwo.org> <20170517145645.GO18247@dhcp22.suse.cz> <alpine.DEB.2.20.1705171021570.9487@east.gentwo.org>
 <20170518090846.GD25462@dhcp22.suse.cz>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Li Zefan <lizefan@huawei.com>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-api@vger.kernel.org

On Thu, 18 May 2017, Michal Hocko wrote:

> > Nope. The OOM in a cpuset gets the process doing the alloc killed. Or what
> > that changed?

!!!!!

> >
> > At this point you have messed up royally and nothing is going to rescue
> > you anyways. OOM or not does not matter anymore. The app will fail.
>
> Not really. If you can trick the system to _think_ that the intersection
> between mempolicy and the cpuset is empty then the OOM killer might
> trigger an innocent task rather than the one which tricked it into that
> situation.

See above. OOM Kill in a cpuset does not kill an innocent task but a task
that does an allocation in that specific context meaning a task in that
cpuset that also has a memory policty.

Regardless of that the point earlier was that the moving logic can avoid
creating temporary situations of empty sets of nodes by analysing the
memory policies etc and only performing moves when doing so is safe.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

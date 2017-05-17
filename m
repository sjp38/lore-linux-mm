Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id B27466B0038
	for <linux-mm@kvack.org>; Wed, 17 May 2017 11:25:11 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id z15so10829261ite.14
        for <linux-mm@kvack.org>; Wed, 17 May 2017 08:25:11 -0700 (PDT)
Received: from resqmta-ch2-03v.sys.comcast.net (resqmta-ch2-03v.sys.comcast.net. [2001:558:fe21:29:69:252:207:35])
        by mx.google.com with ESMTPS id r88si2505682ioi.156.2017.05.17.08.25.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 May 2017 08:25:10 -0700 (PDT)
Date: Wed, 17 May 2017 10:25:09 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC 1/6] mm, page_alloc: fix more premature OOM due to race
 with cpuset update
In-Reply-To: <20170517145645.GO18247@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.20.1705171021570.9487@east.gentwo.org>
References: <a86ae57a-3efc-6ae5-ddf0-fd64c53c20fa@suse.cz> <alpine.DEB.2.20.1704121617040.28335@east.gentwo.org> <cf9628e9-20ed-68b0-6cbd-48af5133138c@suse.cz> <alpine.DEB.2.20.1704141526260.17435@east.gentwo.org> <fda99ddc-94f5-456e-6560-d4991da452a6@suse.cz>
 <alpine.DEB.2.20.1704301628460.21533@east.gentwo.org> <20170517092042.GH18247@dhcp22.suse.cz> <alpine.DEB.2.20.1705170855430.7925@east.gentwo.org> <20170517140501.GM18247@dhcp22.suse.cz> <alpine.DEB.2.20.1705170943090.8714@east.gentwo.org>
 <20170517145645.GO18247@dhcp22.suse.cz>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Li Zefan <lizefan@huawei.com>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-api@vger.kernel.org

On Wed, 17 May 2017, Michal Hocko wrote:

> > If you have screwy things like static mbinds in there then you are
> > hopelessly lost anyways. You may have moved the process to another set
> > of nodes but the static bindings may refer to a node no longer
> > available. Thus the OOM is legitimate.
>
> The point is that you do _not_ want such a process to trigger the OOM
> because it can cause other processes being killed.

Nope. The OOM in a cpuset gets the process doing the alloc killed. Or what
that changed?

At this point you have messed up royally and nothing is going to rescue
you anyways. OOM or not does not matter anymore. The app will fail.

> > At least a user space app could inspect
> > the situation and come up with custom ways of dealing with the mess.
>
> I do not really see how would this help to prevent a malicious user from
> playing tricks.

How did a malicious user come into this? Of course you can mess up in
significant ways if you can overflow nodes and cause an app that has
restrictions to fail but nothing is going to change that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

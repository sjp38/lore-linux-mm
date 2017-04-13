Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 816D06B0397
	for <linux-mm@kvack.org>; Thu, 13 Apr 2017 02:07:23 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id z62so5244343wrc.0
        for <linux-mm@kvack.org>; Wed, 12 Apr 2017 23:07:23 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v6si34596965wrd.2.2017.04.12.23.07.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 12 Apr 2017 23:07:22 -0700 (PDT)
Subject: Re: [RFC 1/6] mm, page_alloc: fix more premature OOM due to race with
 cpuset update
References: <20170411140609.3787-1-vbabka@suse.cz>
 <20170411140609.3787-2-vbabka@suse.cz>
 <95469f35-56e9-7dc4-b7fd-a3e8c25bdff3@linux.vnet.ibm.com>
 <2dbcff3c-f0f1-b568-f98c-519dd98c6e63@suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <3dc5ebcf-f8da-99ca-1bd4-6ee734382443@suse.cz>
Date: Thu, 13 Apr 2017 08:07:21 +0200
MIME-Version: 1.0
In-Reply-To: <2dbcff3c-f0f1-b568-f98c-519dd98c6e63@suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Li Zefan <lizefan@huawei.com>, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On 04/13/2017 08:06 AM, Vlastimil Babka wrote:
>> Did you really mean node_zonelist() in both the instances above. Because
>> that function just picks up either FALLBACK_ZONELIST or NOFALLBACK_ZONELIST
>> depending upon the passed GFP flags in the allocation request and does not
>> deal with ignoring the passed nodemask.
> 
> Oops, I meant policy_zonelist(), thanks for noticing.

Nah, policy_nodemask()... I need coffee.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

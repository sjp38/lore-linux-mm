Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id E66756B025E
	for <linux-mm@kvack.org>; Thu, 13 Oct 2016 06:07:12 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id x23so45733418lfi.0
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 03:07:12 -0700 (PDT)
Received: from mail-lf0-f41.google.com (mail-lf0-f41.google.com. [209.85.215.41])
        by mx.google.com with ESMTPS id s63si7880013lja.58.2016.10.13.03.07.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Oct 2016 03:07:11 -0700 (PDT)
Received: by mail-lf0-f41.google.com with SMTP id b75so127325121lfg.3
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 03:07:11 -0700 (PDT)
Date: Thu, 13 Oct 2016 12:07:09 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: MPOL_BIND on memory only nodes
Message-ID: <20161013100708.GI21678@dhcp22.suse.cz>
References: <57FE0184.6030008@linux.vnet.ibm.com>
 <20161012094337.GH17128@dhcp22.suse.cz>
 <20161012131626.GL17128@dhcp22.suse.cz>
 <57FF59EE.9050508@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <57FF59EE.9050508@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Mel Gorman <mgorman@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Balbir Singh <bsingharora@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>

On Thu 13-10-16 15:24:54, Anshuman Khandual wrote:
[...]
> Which makes the function look like this. Even with these changes, MPOL_BIND is
> still going to pick up the local node's zonelist instead of the first node in
> policy->v.nodes nodemask. It completely ignores policy->v.nodes which it should
> not.

Not really. I have tried to explain earlier. We do not ignore policy
nodemask. This one comes from policy_nodemask. We start with the local
node but fallback to some of the nodes from the nodemask defined by the
policy.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

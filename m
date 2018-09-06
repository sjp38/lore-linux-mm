Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8C36B6B7875
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 07:16:03 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id k16-v6so3562783ede.6
        for <linux-mm@kvack.org>; Thu, 06 Sep 2018 04:16:03 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u24-v6si5241284edl.207.2018.09.06.04.16.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Sep 2018 04:16:02 -0700 (PDT)
Subject: Re: [PATCH] mm, thp: relax __GFP_THISNODE for MADV_HUGEPAGE mappings
From: Vlastimil Babka <vbabka@suse.cz>
References: <39BE14E6-D0FB-428A-B062-8B5AEDC06E61@cs.rutgers.edu>
 <20180829162528.GD10223@dhcp22.suse.cz>
 <20180829192451.GG10223@dhcp22.suse.cz>
 <E97C9342-9BA0-48DD-A580-738ACEE49B41@cs.rutgers.edu>
 <20180830070021.GB2656@dhcp22.suse.cz>
 <4AFDF557-46E3-4C62-8A43-C28E8F2A54CF@cs.rutgers.edu>
 <20180830134549.GI2656@dhcp22.suse.cz>
 <C0146217-821B-4530-A2E2-57D4CCDE8102@cs.rutgers.edu>
 <20180830164057.GK2656@dhcp22.suse.cz> <20180905034403.GN4762@redhat.com>
 <20180905070803.GZ14951@dhcp22.suse.cz>
 <99ee1104-9258-e801-2ba3-a643892cc6c1@suse.cz>
Message-ID: <d339247b-18a5-e26d-d402-c44c8cca6cee@suse.cz>
Date: Thu, 6 Sep 2018 13:16:00 +0200
MIME-Version: 1.0
In-Reply-To: <99ee1104-9258-e801-2ba3-a643892cc6c1@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>, Andrea Arcangeli <aarcange@redhat.com>
Cc: Zi Yan <zi.yan@cs.rutgers.edu>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Alex Williamson <alex.williamson@redhat.com>, David Rientjes <rientjes@google.com>, Stefan Priebe - Profihost AG <s.priebe@profihost.ag>

On 09/06/2018 01:10 PM, Vlastimil Babka wrote:
>> We can and should think about this much more but I would like to have
>> this regression closed. So can we address GFP_THISNODE part first and
>> build more complex solution on top?
>>
>> Is there any objection to my patch which does the similar thing to your
>> patch v2 in a different location?
> 
> Similar but not the same. It fixes the madvise case, but I wonder about
> the no-madvise defrag=defer case, where Zi Yan reports it still causes
> swapping.

Ah, but that should be the same with Andrea's variant 2) patch. There
should only be difference with defrag=always, which is direct reclaim
with __GFP_NORETRY, Andrea's patch would drop __GFP_THISNODE and your
not. Maybe Zi Yan can do the same kind of tests with Andrea's patch [1]
to confirm?

[1] https://marc.info/?l=linux-mm&m=153476267026951

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id D39056B46E9
	for <linux-mm@kvack.org>; Tue, 28 Aug 2018 11:24:18 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id w44-v6so971041edb.16
        for <linux-mm@kvack.org>; Tue, 28 Aug 2018 08:24:18 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a24-v6si1435766edt.342.2018.08.28.08.24.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Aug 2018 08:24:17 -0700 (PDT)
Date: Tue, 28 Aug 2018 17:24:14 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 4/7] mm/hmm: properly handle migration pmd
Message-ID: <20180828152414.GQ10223@dhcp22.suse.cz>
References: <20180824192549.30844-1-jglisse@redhat.com>
 <20180824192549.30844-5-jglisse@redhat.com>
 <0560A126-680A-4BAE-8303-F1AB34BE4BA5@cs.rutgers.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0560A126-680A-4BAE-8303-F1AB34BE4BA5@cs.rutgers.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: jglisse@redhat.com, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, "Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>, Ralph Campbell <rcampbell@nvidia.com>, John Hubbard <jhubbard@nvidia.com>

On Fri 24-08-18 20:05:46, Zi Yan wrote:
[...]
> > +	if (!pmd_present(pmd)) {
> > +		swp_entry_t entry = pmd_to_swp_entry(pmd);
> > +
> > +		if (is_migration_entry(entry)) {
> 
> I think you should check thp_migration_supported() here, since PMD migration is only enabled in x86_64 systems.
> Other architectures should treat PMD migration entries as bad.

How can we have a migration pmd entry when the migration is not
supported?

-- 
Michal Hocko
SUSE Labs

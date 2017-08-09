Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id D75FF6B02F4
	for <linux-mm@kvack.org>; Wed,  9 Aug 2017 14:38:36 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id x43so9848842wrb.9
        for <linux-mm@kvack.org>; Wed, 09 Aug 2017 11:38:36 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id m1si4706850eda.34.2017.08.09.11.38.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 09 Aug 2017 11:38:35 -0700 (PDT)
Date: Wed, 9 Aug 2017 14:38:25 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: kernel panic on null pointer on page->mem_cgroup
Message-ID: <20170809183825.GA26387@cmpxchg.org>
References: <20170805155241.GA94821@jaegeuk-macbookpro.roam.corp.google.com>
 <20170808010150.4155-1-bradleybolen@gmail.com>
 <20170808162122.GA14689@cmpxchg.org>
 <20170808165601.GA7693@jaegeuk-macbookpro.roam.corp.google.com>
 <20170808173704.GA22887@cmpxchg.org>
 <CADvgSZSn1v-tTpa07ebqr19heQbkzbavdPM_nbRNR1WF-EBnFw@mail.gmail.com>
 <20170808200849.GA1104@cmpxchg.org>
 <20170809014459.GB7693@jaegeuk-macbookpro.roam.corp.google.com>
 <CADvgSZSNn7N3R7+jjeCgns2ZEPtYc6c3MWmkkQ3PA+0LHO_MfA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CADvgSZSNn7N3R7+jjeCgns2ZEPtYc6c3MWmkkQ3PA+0LHO_MfA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brad Bolen <bradleybolen@gmail.com>
Cc: Jaegeuk Kim <jaegeuk@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Aug 08, 2017 at 10:39:27PM -0400, Brad Bolen wrote:
> Yes, the BUG_ON(!page_count(page)) fired for me as well.

Brad, Jaegeuk, does the following patch address this problem?

---

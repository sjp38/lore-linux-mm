Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 65B4E6B02C0
	for <linux-mm@kvack.org>; Thu, 25 Oct 2018 16:27:12 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id 67-v6so8041149pfm.17
        for <linux-mm@kvack.org>; Thu, 25 Oct 2018 13:27:12 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id e92-v6si8730883pld.45.2018.10.25.13.27.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 25 Oct 2018 13:27:11 -0700 (PDT)
Date: Thu, 25 Oct 2018 13:27:07 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC PATCH] mm: don't reclaim inodes with many attached pages
Message-ID: <20181025202707.GL25444@bombadil.infradead.org>
References: <20181023164302.20436-1-guro@fb.com>
 <20181024151950.36fe2c41957d807756f587ca@linux-foundation.org>
 <20181025092352.GP18839@dhcp22.suse.cz>
 <20181025124442.5513d282273786369bbb7460@linux-foundation.org>
 <20181025202014.GA216405@sasha-vm>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181025202014.GA216405@sasha-vm>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sashal@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Roman Gushchin <guro@fb.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Kernel Team <Kernel-team@fb.com>, Rik van Riel <riel@surriel.com>, Randy Dunlap <rdunlap@infradead.org>, Sasha Levin <Alexander.Levin@microsoft.com>

On Thu, Oct 25, 2018 at 04:20:14PM -0400, Sasha Levin wrote:
> On Thu, Oct 25, 2018 at 12:44:42PM -0700, Andrew Morton wrote:
> > Yup.  Sasha, can you please take care of this?
> 
> Sure, I'll revert it from current stable trees.
> 
> Should 172b06c32b94 and this commit be backported once Roman confirms
> the issue is fixed? As far as I understand 172b06c32b94 addressed an
> issue FB were seeing in their fleet and needed to be fixed.

I'm not sure I see "FB sees an issue in their fleet" and "needs to be
fixed in stable kernels" as related.  FB's workload is different from
most people's workloads and FB has a large and highly-skilled team of
kernel engineers.  Obviously I want this problem fixed in mainline,
but I don't know that most people benefit from having it fixed in stable.

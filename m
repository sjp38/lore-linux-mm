Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9B32F6B0003
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 07:38:54 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id z11-v6so1216284edq.17
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 04:38:54 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p17-v6si2000861edi.276.2018.06.27.04.38.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 27 Jun 2018 04:38:53 -0700 (PDT)
Date: Wed, 27 Jun 2018 13:38:51 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] alpha: switch to NO_BOOTMEM
Message-ID: <20180627113851.GP32348@dhcp22.suse.cz>
References: <1530099168-31421-1-git-send-email-rppt@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1530099168-31421-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, linux-alpha <linux-alpha@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>

On Wed 27-06-18 14:32:48, Mike Rapoport wrote:
> Replace bootmem allocator with memblock and enable use of NO_BOOTMEM like
> on most other architectures.
> 
> The conversion does not take care of NUMA support which is marked broken
> for more than 10 years now.

It would be great to describe how is the conversion done. At least on
high level.
-- 
Michal Hocko
SUSE Labs

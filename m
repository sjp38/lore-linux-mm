Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2D2588E0001
	for <linux-mm@kvack.org>; Mon,  7 Jan 2019 03:43:41 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id m19so27244edc.6
        for <linux-mm@kvack.org>; Mon, 07 Jan 2019 00:43:41 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j1-v6si2060962ejc.323.2019.01.07.00.43.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Jan 2019 00:43:39 -0800 (PST)
Date: Mon, 7 Jan 2019 09:43:38 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: mmotm 2018-12-21-15-28 uploaded
Message-ID: <20190107084338.GW31793@dhcp22.suse.cz>
References: <20181221232853.WLvEi%akpm@linux-foundation.org>
 <99ab6512-9fce-9cb9-76e7-7f83d87d5f86@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <99ab6512-9fce-9cb9-76e7-7f83d87d5f86@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: akpm@linux-foundation.org, broonie@kernel.org, sfr@canb.auug.org.au, linux-next@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mm-commits@vger.kernel.org

Hi,

On Mon 07-01-19 13:02:31, Anshuman Khandual wrote:
> On 12/22/2018 04:58 AM, akpm@linux-foundation.org wrote:
[...]
> > A git tree which contains the memory management portion of this tree is
> > maintained at git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.gi
> 
> Hello Michal,
> 
> I dont see the newer tags on this tree. Tried fetching all the tags from the tree
> but only see these right now for 2018. This release should have an equivalent tag
> (mmotm-2018-12-21-15-28) right ? 

I have stopped tracking mmotm trees in this tree quite some time ago. I
would much rather turn mmotm into a proper git tree which I was
discussing with Andrew but we didn't land in anything so far. I hope to
use LSFMM this year to resurrect the idea. 
-- 
Michal Hocko
SUSE Labs

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 25B098E0001
	for <linux-mm@kvack.org>; Mon,  7 Jan 2019 04:24:00 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id o21so71302edq.4
        for <linux-mm@kvack.org>; Mon, 07 Jan 2019 01:24:00 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y24si1181edo.347.2019.01.07.01.23.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Jan 2019 01:23:58 -0800 (PST)
Date: Mon, 7 Jan 2019 10:23:56 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: mmotm 2018-12-21-15-28 uploaded
Message-ID: <20190107092356.GB31793@dhcp22.suse.cz>
References: <20181221232853.WLvEi%akpm@linux-foundation.org>
 <99ab6512-9fce-9cb9-76e7-7f83d87d5f86@arm.com>
 <20190107084338.GW31793@dhcp22.suse.cz>
 <451ec03f-d669-fcd0-11c7-f7fef9f85a56@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <451ec03f-d669-fcd0-11c7-f7fef9f85a56@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: akpm@linux-foundation.org, broonie@kernel.org, sfr@canb.auug.org.au, linux-next@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mm-commits@vger.kernel.org

On Mon 07-01-19 14:46:43, Anshuman Khandual wrote:
> 
> 
> On 01/07/2019 02:13 PM, Michal Hocko wrote:
> > Hi,
> > 
> > On Mon 07-01-19 13:02:31, Anshuman Khandual wrote:
> >> On 12/22/2018 04:58 AM, akpm@linux-foundation.org wrote:
> > [...]
> >>> A git tree which contains the memory management portion of this tree is
> >>> maintained at git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.gi
> >>
> >> Hello Michal,
> >>
> >> I dont see the newer tags on this tree. Tried fetching all the tags from the tree
> >> but only see these right now for 2018. This release should have an equivalent tag
> >> (mmotm-2018-12-21-15-28) right ? 
> > 
> > I have stopped tracking mmotm trees in this tree quite some time ago. I
> > would much rather turn mmotm into a proper git tree which I was
> > discussing with Andrew but we didn't land in anything so far. I hope to
> > use LSFMM this year to resurrect the idea. 
> >
> 
> Even this tree http://git.cmpxchg.org/cgit.cgi/linux-mmotm.git/ does not clone. So
> right now the only way to construct the latest mmotm tree is through applying all
> the patches mentioned here at http://www.ozlabs.org/~akpm/mmotm/ on linux-next ?

linux-next should contain all of them already.

-- 
Michal Hocko
SUSE Labs

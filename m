Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id C94A66B0022
	for <linux-mm@kvack.org>; Wed, 14 Mar 2018 09:03:16 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id o61-v6so1436565pld.5
        for <linux-mm@kvack.org>; Wed, 14 Mar 2018 06:03:16 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m19-v6si1978817pli.36.2018.03.14.06.03.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 14 Mar 2018 06:03:15 -0700 (PDT)
Date: Wed, 14 Mar 2018 14:03:13 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: mmotm 2018-03-13-15-15 uploaded
Message-ID: <20180314130313.GB23100@dhcp22.suse.cz>
References: <20180313221617.IBhUuE5FL%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180313221617.IBhUuE5FL%akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: broonie@kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-next@vger.kernel.org, mm-commits@vger.kernel.org, sfr@canb.auug.org.au

On Tue 13-03-18 15:16:17, Andrew Morton wrote:
> The mm-of-the-moment snapshot 2018-03-13-15-15 has been uploaded to
[...]
> To develop on top of mmotm git:
> 
>   $ git remote add mmotm git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git
>   $ git remote update mmotm
>   $ git checkout -b topic mmotm/master
>   <make changes, commit>
>   $ git send-email mmotm/master.. [...]

JFYI. After few missed mmotm updates while I was offline the tree is
back up-to-date.
-- 
Michal Hocko
SUSE Labs

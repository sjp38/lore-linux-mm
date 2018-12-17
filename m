Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 933C68E0033
	for <linux-mm@kvack.org>; Mon, 17 Dec 2018 10:36:25 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id d41so8955703eda.12
        for <linux-mm@kvack.org>; Mon, 17 Dec 2018 07:36:25 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f2si1482587edv.276.2018.12.17.07.36.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Dec 2018 07:36:24 -0800 (PST)
Date: Mon, 17 Dec 2018 16:36:23 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [4.20.0-0.rc6] kernel BUG at include/linux/mm.h:990!
Message-ID: <20181217153623.GT30879@dhcp22.suse.cz>
References: <CABXGCsOyHuNpPNMnU0rbMwfGkFA2ooAbkCkyRqC0D-S3ygu-hA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CABXGCsOyHuNpPNMnU0rbMwfGkFA2ooAbkCkyRqC0D-S3ygu-hA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Cc: linux-mm@kvack.org

On Mon 17-12-18 02:50:31, Mikhail Gavrilov wrote:
> Hi guys.
> 
> Today I discovered that `# inxi  --debug 22` causes kernel BUG at
> include/linux/mm.h:990

Does [1] fix your problem?

[1] http://lkml.kernel.org/r/20181212172712.34019-2-zaslonko@linux.ibm.com
-- 
Michal Hocko
SUSE Labs

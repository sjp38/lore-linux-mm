Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id B5AB36B0012
	for <linux-mm@kvack.org>; Wed, 28 Mar 2018 08:58:34 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id o23so1148288wrc.9
        for <linux-mm@kvack.org>; Wed, 28 Mar 2018 05:58:34 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 13si2718494wrb.468.2018.03.28.05.58.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 28 Mar 2018 05:58:33 -0700 (PDT)
Date: Wed, 28 Mar 2018 14:58:30 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: =?utf-8?B?562U5aSNOg==?= Too easy OOM
Message-ID: <20180328125830.GA8976@dhcp22.suse.cz>
References: <2AD939572F25A448A3AE3CAEA61328C23750D4E0@BC-MAIL-M28.internal.baidu.com>
 <CAKEcN828eqXN8zhKgzu+Mf-vdXC8o_LOmxwWZ4vayrdvmpdPFQ@mail.gmail.com>
 <2AD939572F25A448A3AE3CAEA61328C237512B38@BC-MAIL-M28.internal.baidu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2AD939572F25A448A3AE3CAEA61328C237512B38@BC-MAIL-M28.internal.baidu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Li,Rongqing" <lirongqing@baidu.com>
Cc: Austin Kim <austincrashtool@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Wed 28-03-18 01:34:24, Li,Rongqing wrote:
> OK, I see this commit, I will test the latest kernel
> 
> commit 1c610d5f93c709df56787f50b3576704ac271826
> Author: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Date:   Thu Mar 22 16:17:42 2018 -0700

Yes, that should fix your memcg OOM
-- 
Michal Hocko
SUSE Labs

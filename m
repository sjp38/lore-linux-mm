Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id C5EC96B005A
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 16:48:39 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id z2-v6so10344109plk.3
        for <linux-mm@kvack.org>; Tue, 10 Apr 2018 13:48:39 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id i188si2271802pgc.178.2018.04.10.13.48.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Apr 2018 13:48:38 -0700 (PDT)
Date: Tue, 10 Apr 2018 13:48:37 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3] writeback: safer lock nesting
Message-Id: <20180410134837.d2b0f2d1cd940bb08c2bad0a@linux-foundation.org>
In-Reply-To: <20180410063357.GS21835@dhcp22.suse.cz>
References: <201804080259.VS5U0mKT%fengguang.wu@intel.com>
	<20180410005908.167976-1-gthelen@google.com>
	<20180410063357.GS21835@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Greg Thelen <gthelen@google.com>, Wang Long <wanglong19@meituan.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, npiggin@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 10 Apr 2018 08:33:57 +0200 Michal Hocko <mhocko@kernel.org> wrote:

> > Reported-by: Wang Long <wanglong19@meituan.com>
> > Signed-off-by: Greg Thelen <gthelen@google.com>
> > Change-Id: Ibb773e8045852978f6207074491d262f1b3fb613
> 
> Not a stable material IMHO

Why's that?  Wang Long said he's observed the deadlock three times?

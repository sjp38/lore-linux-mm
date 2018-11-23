Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7E0DF6B3125
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 08:39:05 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id l45so5815882edb.1
        for <linux-mm@kvack.org>; Fri, 23 Nov 2018 05:39:05 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n1si8666197edq.35.2018.11.23.05.39.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Nov 2018 05:39:04 -0800 (PST)
Date: Fri, 23 Nov 2018 14:39:02 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm/slub: improve performance by skipping checked node
 in get_any_partial()
Message-ID: <20181123133902.GS8625@dhcp22.suse.cz>
References: <20181108011204.9491-1-richard.weiyang@gmail.com>
 <20181120033119.30013-1-richard.weiyang@gmail.com>
 <20181121190555.c010ac50e7eaa141549a63e5@linux-foundation.org>
 <20181122234159.5hrhxioe6b777ttb@master>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181122234159.5hrhxioe6b777ttb@master>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, cl@linux.com, penberg@kernel.org, linux-mm@kvack.org

On Thu 22-11-18 23:41:59, Wei Yang wrote:
> On Wed, Nov 21, 2018 at 07:05:55PM -0800, Andrew Morton wrote:
[...]
> >> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
> 
> Reviewed-by: Wei Yang <richard.weiyang@gmail.com>

Why would you want to add reviewed tag to your own patch? Isn't the
s-o-b a sufficient sign of you being and author of the patch and
therefore the one who has reviewed the change before asking for merging?

Btw. Documentation/SubmittingPatches might come handy to understand the
process some more. Feel free to ask if there is something unclear.
-- 
Michal Hocko
SUSE Labs

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id E6A7A6B743C
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 07:11:57 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id b7so9769950eda.10
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 04:11:57 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r2-v6si1123660ejn.298.2018.12.05.04.11.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Dec 2018 04:11:56 -0800 (PST)
Date: Wed, 5 Dec 2018 13:11:55 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] admin-guide/memory-hotplug.rst: remove locking
 internal part from admin-guide
Message-ID: <20181205121155.GJ1286@dhcp22.suse.cz>
References: <20181205023426.24029-1-richard.weiyang@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181205023426.24029-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: david@redhat.com, osalvador@suse.de, akpm@linux-foundation.org, linux-doc@vger.kernel.org, linux-mm@kvack.org

On Wed 05-12-18 10:34:25, Wei Yang wrote:
> Locking Internal section exists in core-api documentation, which is more
> suitable for this.
> 
> This patch removes the duplication part here.
> 
> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>

Yes this doesn't really make any sense in an admin guide. It is a pure
implementation detail nobody should be relying on.
-- 
Michal Hocko
SUSE Labs

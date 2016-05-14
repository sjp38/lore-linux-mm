Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 24B716B0005
	for <linux-mm@kvack.org>; Sat, 14 May 2016 12:14:13 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id 68so50884444lfq.2
        for <linux-mm@kvack.org>; Sat, 14 May 2016 09:14:13 -0700 (PDT)
Received: from vena.lwn.net (tex.lwn.net. [70.33.254.29])
        by mx.google.com with ESMTPS id 204si9810128wmc.124.2016.05.14.09.14.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 14 May 2016 09:14:11 -0700 (PDT)
Date: Sat, 14 May 2016 10:13:13 -0600
From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: [PATCH] Documentation/memcg: update kmem limit doc as codes
 behavior
Message-ID: <20160514101313.34fde503@lwn.net>
In-Reply-To: <5732CC23.2060101@huawei.com>
References: <572B0105.50503@huawei.com>
	<20160505083221.GD4386@dhcp22.suse.cz>
	<5732CC23.2060101@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qiang Huang <h.huangqiang@huawei.com>
Cc: Michal Hocko <mhocko@kernel.org>, tj@kernel.org, Zefan Li <lizefan@huawei.com>, hannes@cmpxchg.org, akpm@linux-foundation.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Wed, 11 May 2016 14:07:31 +0800
Qiang Huang <h.huangqiang@huawei.com> wrote:

> The restriction of kmem setting is not there anymore because the
> accounting is enabled by default even in the cgroup v1 - see
> b313aeee2509 ("mm: memcontrol: enable kmem accounting for all
> cgroups in the legacy hierarchy").
> 
> Update docs accordingly.

Applied to the docs tree, thanks.

jon

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

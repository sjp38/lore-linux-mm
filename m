Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id DF10B6B0035
	for <linux-mm@kvack.org>; Wed, 16 Oct 2013 23:51:23 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id z10so2021658pdj.2
        for <linux-mm@kvack.org>; Wed, 16 Oct 2013 20:51:23 -0700 (PDT)
Received: by mail-pd0-f179.google.com with SMTP id v10so2033369pde.10
        for <linux-mm@kvack.org>; Wed, 16 Oct 2013 20:51:20 -0700 (PDT)
Date: Wed, 16 Oct 2013 20:51:18 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [bug] get_maintainer.pl incomplete output
In-Reply-To: <alpine.DEB.2.02.1310161738410.10147@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.02.1310162046090.30995@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1310161738410.10147@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Anton Vorontsov <anton.vorontsov@linaro.org>, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Joe,

I haven't looked closely at scripts/get_maintainer.pl, but I recently 
wrote a patch touching mm/vmpressure.c and it doesn't list the file's 
author, Anton Vorontsov <anton.vorontsov@linaro.org>.

Even when I do scripts/get_maintainer.pl -f mm/vmpressure.c, his entry is 
missing and git blame attributs >90% of the lines to his authorship.

$ ./scripts/get_maintainer.pl -f mm/vmpressure.c 
Tejun Heo <tj@kernel.org> (commit_signer:6/7=86%)
Michal Hocko <mhocko@suse.cz> (commit_signer:5/7=71%)
Andrew Morton <akpm@linux-foundation.org> (commit_signer:4/7=57%)
Li Zefan <lizefan@huawei.com> (commit_signer:3/7=43%)
"Kirill A. Shutemov" <kirill@shutemov.name> (commit_signer:1/7=14%)
linux-mm@kvack.org (open list:MEMORY MANAGEMENT)
linux-kernel@vger.kernel.org (open list)

Any ideas?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

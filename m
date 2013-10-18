Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 3D3F16B0194
	for <linux-mm@kvack.org>; Fri, 18 Oct 2013 18:58:46 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id bj1so5270079pad.14
        for <linux-mm@kvack.org>; Fri, 18 Oct 2013 15:58:45 -0700 (PDT)
Received: from psmtp.com ([74.125.245.182])
        by mx.google.com with SMTP id kg8si2555605pad.154.2013.10.18.15.58.44
        for <linux-mm@kvack.org>;
        Fri, 18 Oct 2013 15:58:45 -0700 (PDT)
Received: by mail-pb0-f52.google.com with SMTP id wy17so1503647pbc.39
        for <linux-mm@kvack.org>; Fri, 18 Oct 2013 15:58:43 -0700 (PDT)
Date: Fri, 18 Oct 2013 15:58:41 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [bug] get_maintainer.pl incomplete output
In-Reply-To: <1382069821.22110.168.camel@joe-AO722>
Message-ID: <alpine.DEB.2.02.1310181557020.20283@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1310161738410.10147@chino.kir.corp.google.com> <alpine.DEB.2.02.1310162046090.30995@chino.kir.corp.google.com> <20131017121215.826ab6cced73118f3dba8d4f@linux-foundation.org> <1382069821.22110.168.camel@joe-AO722>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Anton Vorontsov <anton.vorontsov@linaro.org>, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 17 Oct 2013, Joe Perches wrote:

> Try this:
> 
> It adds authored/lines_added/lines_deleted to rolestats
> 
> For instance:
> 
> $ ./scripts/get_maintainer.pl -f mm/vmpressure.c
> Tejun Heo <tj@kernel.org> (commit_signer:6/7=86%,authored:3/7=43%,removed_lines:15/21=71%)
> Michal Hocko <mhocko@suse.cz> (commit_signer:5/7=71%,authored:3/7=43%,added_lines:22/408=5%,removed_lines:6/21=29%)
> Andrew Morton <akpm@linux-foundation.org> (commit_signer:4/7=57%)
> Li Zefan <lizefan@huawei.com> (commit_signer:3/7=43%)
> "Kirill A. Shutemov" <kirill@shutemov.name> (commit_signer:1/7=14%)
> Anton Vorontsov <anton.vorontsov@linaro.org> (authored:1/7=14%,added_lines:374/408=92%)
> linux-mm@kvack.org (open list:MEMORY MANAGEMENT)
> linux-kernel@vger.kernel.org (open list)
> 
> I haven't tested it much.
> 

This looks good, thanks very much!  I'm not sure how useful the 
removed_lines stat is, but perhaps it can be useful for someone to chime 
in if someone proposes a patch that includes support that had already been 
removed.

Once it's signed off, feel free to add

	Acked-by: David Rientjes <rientjes@google.com>

Thanks again.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

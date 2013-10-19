Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 19F376B019E
	for <linux-mm@kvack.org>; Fri, 18 Oct 2013 20:26:05 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id kx10so5331880pab.41
        for <linux-mm@kvack.org>; Fri, 18 Oct 2013 17:26:04 -0700 (PDT)
Received: from psmtp.com ([74.125.245.145])
        by mx.google.com with SMTP id cj2si2084165pbc.327.2013.10.18.17.26.02
        for <linux-mm@kvack.org>;
        Fri, 18 Oct 2013 17:26:03 -0700 (PDT)
Message-ID: <1382142357.2041.12.camel@joe-AO722>
Subject: Re: [bug] get_maintainer.pl incomplete output
From: Joe Perches <joe@perches.com>
Date: Fri, 18 Oct 2013 17:25:57 -0700
In-Reply-To: <alpine.DEB.2.02.1310181557020.20283@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1310161738410.10147@chino.kir.corp.google.com>
	 <alpine.DEB.2.02.1310162046090.30995@chino.kir.corp.google.com>
	 <20131017121215.826ab6cced73118f3dba8d4f@linux-foundation.org>
	 <1382069821.22110.168.camel@joe-AO722>
	 <alpine.DEB.2.02.1310181557020.20283@chino.kir.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Anton Vorontsov <anton.vorontsov@linaro.org>, Michal Hocko <mhocko@suse.cz>, "Kirill A.
 Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 2013-10-18 at 15:58 -0700, David Rientjes wrote:
> On Thu, 17 Oct 2013, Joe Perches wrote:
> > Try this:
> > It adds authored/lines_added/lines_deleted to rolestats
> > For instance:
> > $ ./scripts/get_maintainer.pl -f mm/vmpressure.c
> > Tejun Heo <tj@kernel.org> (commit_signer:6/7=86%,authored:3/7=43%,removed_lines:15/21=71%)
> > Michal Hocko <mhocko@suse.cz> (commit_signer:5/7=71%,authored:3/7=43%,added_lines:22/408=5%,removed_lines:6/21=29%)
> > Andrew Morton <akpm@linux-foundation.org> (commit_signer:4/7=57%)
> > Li Zefan <lizefan@huawei.com> (commit_signer:3/7=43%)
> > "Kirill A. Shutemov" <kirill@shutemov.name> (commit_signer:1/7=14%)
> > Anton Vorontsov <anton.vorontsov@linaro.org> (authored:1/7=14%,added_lines:374/408=92%)
> > linux-mm@kvack.org (open list:MEMORY MANAGEMENT)
> > linux-kernel@vger.kernel.org (open list)
> > 
> > I haven't tested it much.
> This looks good, thanks very much!

Oh sure, it's a trifle.

> I'm not sure how useful the 
> removed_lines stat is, but perhaps it can be useful for someone to chime 
> in if someone proposes a patch that includes support that had already been 
> removed.

The whole concept of lines +/- is kind of dubious.
Quantity really doesn't judge value.

It makes some sense for patches where new files
are added, but new files are a relatively a small
percentage of the overall kernel source tree.

Let it stew for awhile in Andrew's tree and when
-next opens up again, let's see if there are any
other comments about it.

My guess is very few people will notice.

The best mechanism is to have MAINTAINERS entries.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

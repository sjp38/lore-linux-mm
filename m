Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 1C6E16B0035
	for <linux-mm@kvack.org>; Thu, 17 Oct 2013 00:36:33 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id y13so2074526pdi.12
        for <linux-mm@kvack.org>; Wed, 16 Oct 2013 21:36:31 -0700 (PDT)
Message-ID: <1381984585.22110.92.camel@joe-AO722>
Subject: Re: [bug] get_maintainer.pl incomplete output
From: Joe Perches <joe@perches.com>
Date: Wed, 16 Oct 2013 21:36:25 -0700
In-Reply-To: <alpine.DEB.2.02.1310162117140.2453@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1310161738410.10147@chino.kir.corp.google.com>
	 <alpine.DEB.2.02.1310162046090.30995@chino.kir.corp.google.com>
	 <1381982635.22110.84.camel@joe-AO722>
	 <alpine.DEB.2.02.1310162117140.2453@chino.kir.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Anton Vorontsov <anton.vorontsov@linaro.org>, Michal Hocko <mhocko@suse.cz>, "Kirill A.
 Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 2013-10-16 at 21:19 -0700, David Rientjes wrote:
> On Wed, 16 Oct 2013, Joe Perches wrote:
> 
> > > I haven't looked closely at scripts/get_maintainer.pl, but I recently 
> > > wrote a patch touching mm/vmpressure.c and it doesn't list the file's 
> > > author, Anton Vorontsov <anton.vorontsov@linaro.org>.
> > > 
> > > Even when I do scripts/get_maintainer.pl -f mm/vmpressure.c, his entry is 
> > > missing and git blame attributs >90% of the lines to his authorship.
> > > 
> > > $ ./scripts/get_maintainer.pl -f mm/vmpressure.c 
> > > Tejun Heo <tj@kernel.org> (commit_signer:6/7=86%)
> > > Michal Hocko <mhocko@suse.cz> (commit_signer:5/7=71%)
> > > Andrew Morton <akpm@linux-foundation.org> (commit_signer:4/7=57%)
> > > Li Zefan <lizefan@huawei.com> (commit_signer:3/7=43%)
> > > "Kirill A. Shutemov" <kirill@shutemov.name> (commit_signer:1/7=14%)
> > > linux-mm@kvack.org (open list:MEMORY MANAGEMENT)
> > > linux-kernel@vger.kernel.org (open list)
> > > 
> > > Any ideas?
> > 
> > get_maintainer has a lot of options.
> > 
> > get_maintainer tries to find people that are either
> > listed in the MAINTAINERS file or that have recently
> > (in the last year by default) worked on the file.
> > 
> > If you want to find all authors, use the --git-blame option
> > 
> > It's not the default because it can take quite awhile to run.
> > 
> 
> Hmm, it's a little strange to only consider recent activity when >90% of 
> the lines were written by someone not listed.  Isn't there any faster way 
> to determine that besides using the expensive git blame?

Not so far as I know.

> Something like 
> weighing the output of "git show --shortstat" for all commits in "git log 
> mm/vmpressure.c" to determine the most important recent changes?  That 
> should be fairly cheap.

Important can be hard to determine.

git blame effectively does a --follow

get_maintainers already does a git log <file>
and accumulates all the signatures for the
time selected by --git-since

It doesn't weight each commit by +/- count.

I think the most significant negative to
the current get_maintainer is that only the
"signature" lines are considered.

The "Author:" line isn't.

The default ris for get_maintainer to only list
a maximum of 5 "maintainers" ordered by signature
count.

Anton has only signed/acked 1.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

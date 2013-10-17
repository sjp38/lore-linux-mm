Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id A08726B00C2
	for <linux-mm@kvack.org>; Thu, 17 Oct 2013 15:24:04 -0400 (EDT)
Received: by mail-pb0-f42.google.com with SMTP id un15so2734489pbc.29
        for <linux-mm@kvack.org>; Thu, 17 Oct 2013 12:24:04 -0700 (PDT)
Message-ID: <1382037835.22110.137.camel@joe-AO722>
Subject: Re: [bug] get_maintainer.pl incomplete output
From: Joe Perches <joe@perches.com>
Date: Thu, 17 Oct 2013 12:23:55 -0700
In-Reply-To: <20131017121215.826ab6cced73118f3dba8d4f@linux-foundation.org>
References: <alpine.DEB.2.02.1310161738410.10147@chino.kir.corp.google.com>
	 <alpine.DEB.2.02.1310162046090.30995@chino.kir.corp.google.com>
	 <20131017121215.826ab6cced73118f3dba8d4f@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Anton Vorontsov <anton.vorontsov@linaro.org>, Michal Hocko <mhocko@suse.cz>, "Kirill A.
 Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 2013-10-17 at 12:12 -0700, Andrew Morton wrote:
> On Wed, 16 Oct 2013 20:51:18 -0700 (PDT) David Rientjes <rientjes@google.com> wrote:
> 
> > I haven't looked closely at scripts/get_maintainer.pl, but I recently 
> > wrote a patch touching mm/vmpressure.c and it doesn't list the file's 
> > author, Anton Vorontsov <anton.vorontsov@linaro.org>.
> > 
> > Even when I do scripts/get_maintainer.pl -f mm/vmpressure.c, his entry is 
> > missing and git blame attributs >90% of the lines to his authorship.
> > 
> > $ ./scripts/get_maintainer.pl -f mm/vmpressure.c 
> > Tejun Heo <tj@kernel.org> (commit_signer:6/7=86%)
> > Michal Hocko <mhocko@suse.cz> (commit_signer:5/7=71%)
> > Andrew Morton <akpm@linux-foundation.org> (commit_signer:4/7=57%)
> > Li Zefan <lizefan@huawei.com> (commit_signer:3/7=43%)
> > "Kirill A. Shutemov" <kirill@shutemov.name> (commit_signer:1/7=14%)
> > linux-mm@kvack.org (open list:MEMORY MANAGEMENT)
> > linux-kernel@vger.kernel.org (open list)
> 
> get_maintainer should, by default, answer the question "who should I
> email about this file".  It clearly isn't doing this, and that's a
> pretty big fail.

I disagree.

It's decidedly good at doing precisely that when a
MAINTAINERS entry exists.

When no one is a listed maintainer, the results
can certainly be tweaked to be better.

> I've learned not to trust it, so when I use it I always have to check
> its homework with "git log | grep Author" :(
> 
> Joe, pretty please?

It's really a question of "how long ago is too long ago" as
older commits way too often also show old/invalid email
addresses.

I also don't want to wait over 30 seconds or so to find out
who is listed as a git signer/author by default.

Adding the commit listed "Author:" as a signer doesn't seem
too hard though.  I'll play with that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

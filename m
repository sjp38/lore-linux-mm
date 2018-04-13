Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 92A9E6B0007
	for <linux-mm@kvack.org>; Fri, 13 Apr 2018 08:44:46 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id u13so4884149wre.1
        for <linux-mm@kvack.org>; Fri, 13 Apr 2018 05:44:46 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q33si2467203eda.48.2018.04.13.05.44.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 13 Apr 2018 05:44:45 -0700 (PDT)
Date: Fri, 13 Apr 2018 14:44:41 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 0/2] Fix __GFP_ZERO vs constructor
Message-ID: <20180413124441.GB17670@dhcp22.suse.cz>
References: <20180411060320.14458-1-willy@infradead.org>
 <20180412005451.GB253442@rodete-desktop-imager.corp.google.com>
 <20180412192424.GB21205@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180412192424.GB21205@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Chris Fries <cfries@google.com>, jaegeuk@kernel.org

On Thu 12-04-18 12:24:24, Matthew Wilcox wrote:
> On Thu, Apr 12, 2018 at 09:54:51AM +0900, Minchan Kim wrote:
> > Matthew,
> > 
> > Please Cced relevant people so they know what's going on the problem
> > they spent on much time. Everyone doesn't keep an eye on mailing list.
> 
> My apologies; I assumed that git send-email would pick up the people
> named in the changelog.  I have now read the source code and discovered
> it only picks up the people listed in Signed-off-by: and Cc:.  That
> surprises me; I'll submit a patch.

I remember that there was a discussion to add support for more
$Foo-by: $EMAIL

but I do not remember the outcome of the discussion and from a quick
glance into the perl disaster it doesn't seem to handle generic tags.
I am using the following
$ cat cc-cmd.sh
#!/bin/bash

if [[ $1 == *gitsendemail.msg* || $1 == *cover-letter* ]]; then
        grep '<.*@.*>' -h *.patch | sed 's/^.*: //' | sort | uniq
else
        grep '<.*@.*>' -h $1 | sed 's/^.*: //' | sort | uniq
fi

and use it as --cc-cmd=
-- 
Michal Hocko
SUSE Labs

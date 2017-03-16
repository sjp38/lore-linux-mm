Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 87F496B038C
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 06:33:08 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id y51so7619237wry.6
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 03:33:08 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d10si3967193wma.109.2017.03.16.03.33.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 16 Mar 2017 03:33:07 -0700 (PDT)
Date: Thu, 16 Mar 2017 11:33:06 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 02/15] mm: page_alloc: align arguments to parenthesis
Message-ID: <20170316103306.GI30501@dhcp22.suse.cz>
References: <cover.1489628477.git.joe@perches.com>
 <317ef9c31dba4c02905ad0222761b4337f081411.1489628477.git.joe@perches.com>
 <20170316080240.GB30501@dhcp22.suse.cz>
 <1489660167.13953.1.camel@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1489660167.13953.1.camel@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu 16-03-17 03:29:27, Joe Perches wrote:
> On Thu, 2017-03-16 at 09:02 +0100, Michal Hocko wrote:
> > On Wed 15-03-17 18:59:59, Joe Perches wrote:
> > > whitespace changes only - git diff -w shows no difference
> > 
> > what is the point of this whitespace noise? Does it help readability?
> 
> Yes.  Consistency helps.

Causing context conflicts doesn't though.

> > To be honest I do not think so.
> 
> Opinions always vary.

Yes the vary and I do not like this. If you find somebody to ack then I
will not complain but I would appreciate if a more useful stuff was done
in mm/page_alloc.c
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

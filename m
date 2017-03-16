Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3FAEB6B038A
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 06:29:35 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id g138so42031906itb.4
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 03:29:35 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0140.hostedemail.com. [216.40.44.140])
        by mx.google.com with ESMTPS id p127si5666484iop.172.2017.03.16.03.29.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Mar 2017 03:29:34 -0700 (PDT)
Message-ID: <1489660167.13953.1.camel@perches.com>
Subject: Re: [PATCH 02/15] mm: page_alloc: align arguments to parenthesis
From: Joe Perches <joe@perches.com>
Date: Thu, 16 Mar 2017 03:29:27 -0700
In-Reply-To: <20170316080240.GB30501@dhcp22.suse.cz>
References: <cover.1489628477.git.joe@perches.com>
	 <317ef9c31dba4c02905ad0222761b4337f081411.1489628477.git.joe@perches.com>
	 <20170316080240.GB30501@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 2017-03-16 at 09:02 +0100, Michal Hocko wrote:
> On Wed 15-03-17 18:59:59, Joe Perches wrote:
> > whitespace changes only - git diff -w shows no difference
> 
> what is the point of this whitespace noise? Does it help readability?

Yes.  Consistency helps.

> To be honest I do not think so.

Opinions always vary.

>  Such a patch would make sense only if it
> was a part of a larger series where other patches would actually do
> something useful.

Do please read the 0/n introduction to this series.

And do remember to always strip the useless stuff you
unnecessarily quoted too.  66kb in this case.

There was a separate patch series 0/3 that actually did
the more useful stuff.

This patch series was purposely separated.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

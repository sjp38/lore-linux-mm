Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0E0DB6B0007
	for <linux-mm@kvack.org>; Fri, 13 Apr 2018 12:03:34 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id a38so3190378wra.10
        for <linux-mm@kvack.org>; Fri, 13 Apr 2018 09:03:34 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r53si6412231edd.42.2018.04.13.09.03.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 13 Apr 2018 09:03:32 -0700 (PDT)
Date: Fri, 13 Apr 2018 18:03:31 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH RFC 0/8] mm: online/offline 4MB chunks controlled by
 device driver
Message-ID: <20180413160331.GZ17484@dhcp22.suse.cz>
References: <20180413131632.1413-1-david@redhat.com>
 <20180413134414.GS17484@dhcp22.suse.cz>
 <85887556-9497-4beb-261e-6cba46794c9c@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <85887556-9497-4beb-261e-6cba46794c9c@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org

On Fri 13-04-18 17:02:17, David Hildenbrand wrote:
> On 13.04.2018 15:44, Michal Hocko wrote:
> > [If you choose to not CC the same set of people on all patches - which
> > is sometimes a legit thing to do - then please cc them to the cover
> > letter at least.]
> 
> BTW, sorry for that. The list of people to cc was just too big to handle
> manually, so I used get_maintainers.sh with git for the same time ...
> something I will most likely avoid next time :)

I usually have Cc: in all commits and then use the following script as
--cc-cmd. You just have to git format-patch the series and then
git send-email --cc-cmd=./cc-cmd.sh *.patch
+ some mailing lists

#!/bin/bash

if [[ $1 == *gitsendemail.msg* || $1 == *cover-letter* ]]; then
        grep '<.*@.*>' -h *.patch | sed 's/^.*: //' | sort | uniq
fi
-- 
Michal Hocko
SUSE Labs

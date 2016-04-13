Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 5959C828DF
	for <linux-mm@kvack.org>; Wed, 13 Apr 2016 09:33:50 -0400 (EDT)
Received: by mail-wm0-f53.google.com with SMTP id u206so78335167wme.1
        for <linux-mm@kvack.org>; Wed, 13 Apr 2016 06:33:50 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id s1si1281319wme.105.2016.04.13.06.33.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Apr 2016 06:33:49 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id a140so14043326wma.2
        for <linux-mm@kvack.org>; Wed, 13 Apr 2016 06:33:48 -0700 (PDT)
Date: Wed, 13 Apr 2016 15:33:47 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: CC in git cover letter vs patches (was Re: [PATCH 0/19] get rid
 of superfluous __GFP_REPORT)
Message-ID: <20160413133347.GJ14351@dhcp22.suse.cz>
References: <1460372892-8157-1-git-send-email-mhocko@kernel.org>
 <570E2BC1.8050809@synopsys.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <570E2BC1.8050809@synopsys.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Cc: lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, git@vger.kernel.org

On Wed 13-04-16 16:51:37, Vineet Gupta wrote:
> Trimming CC list + CC git folks
> 
> Hi Michal,
> 
> On Monday 11 April 2016 04:37 PM, Michal Hocko wrote:
> > Hi,
> > this is the second version of the patchset previously sent [1]
> 
> I have a git question if you didn't mind w.r.t. this series. Maybe there's an
> obvious answer... I'm using git 2.5.0
> 
> I was wondering how you manage to union the individual patch CC in just the cover
> letter w/o bombarding everyone with everything.

I am using the following flow:

$ rm *.patch
$ for format-patch range
$ git send-email [--to resp. --cc for all patches] --cc-cmd ./cc-cmd-only-cover.sh --compose *.patch

$ cat ./cc-cmd-only-cover.sh 
#!/bin/bash

# --compose with generate *gitsendemail.msg file
# --cover-letter expects *cover-letter* file
if [[ $1 == *gitsendemail.msg* || $1 == *cover-letter* ]]; then
        grep '<.*@.*>' -h *.patch | sed 's/^.*: //' | sort | uniq
fi

it is a little bit coarse and it would be great if git had a default
option for that but this seems to be working just fine for patch-bombs
where the recipients only have to care about their parts and the cover
for the overal idea of the change.

HTH
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

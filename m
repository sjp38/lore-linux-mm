Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 9BA5B828DF
	for <linux-mm@kvack.org>; Wed, 13 Apr 2016 07:21:51 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id fs9so13200296pac.2
        for <linux-mm@kvack.org>; Wed, 13 Apr 2016 04:21:51 -0700 (PDT)
Received: from smtprelay.synopsys.com (us01smtprelay-2.synopsys.com. [198.182.47.9])
        by mx.google.com with ESMTPS id y19si869473pfa.62.2016.04.13.04.21.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Apr 2016 04:21:50 -0700 (PDT)
Subject: CC in git cover letter vs patches (was Re: [PATCH 0/19] get rid of
 superfluous __GFP_REPORT)
References: <1460372892-8157-1-git-send-email-mhocko@kernel.org>
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Message-ID: <570E2BC1.8050809@synopsys.com>
Date: Wed, 13 Apr 2016 16:51:37 +0530
MIME-Version: 1.0
In-Reply-To: <1460372892-8157-1-git-send-email-mhocko@kernel.org>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, git@vger.kernel.org

Trimming CC list + CC git folks

Hi Michal,

On Monday 11 April 2016 04:37 PM, Michal Hocko wrote:
> Hi,
> this is the second version of the patchset previously sent [1]

I have a git question if you didn't mind w.r.t. this series. Maybe there's an
obvious answer... I'm using git 2.5.0

I was wondering how you manage to union the individual patch CC in just the cover
letter w/o bombarding everyone with everything.

Thx,
-Vineet

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

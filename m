Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 769D18309D
	for <linux-mm@kvack.org>; Thu, 18 Aug 2016 10:58:39 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id p85so14174295lfg.3
        for <linux-mm@kvack.org>; Thu, 18 Aug 2016 07:58:39 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id fs16si2266594wjc.230.2016.08.18.07.58.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Aug 2016 07:58:38 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id q128so14413wma.1
        for <linux-mm@kvack.org>; Thu, 18 Aug 2016 07:58:38 -0700 (PDT)
Date: Thu, 18 Aug 2016 16:58:36 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] proc, smaps: reduce printing overhead
Message-ID: <20160818145835.GP30162@dhcp22.suse.cz>
References: <1471519888-13829-1-git-send-email-mhocko@kernel.org>
 <1471526765.4319.31.camel@perches.com>
 <20160818142616.GN30162@dhcp22.suse.cz>
 <20160818144149.GO30162@dhcp22.suse.cz>
 <1471531563.4319.41.camel@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1471531563.4319.41.camel@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Jann Horn <jann@thejh.net>

On Thu 18-08-16 07:46:03, Joe Perches wrote:
> On Thu, 2016-08-18 at 16:41 +0200, Michal Hocko wrote:
> > On Thu 18-08-16 16:26:16, Michal Hocko wrote:
> > > b) doesn't it try to be overly clever when doing that in the caller
> > > doesn't cost all that much? Sure you can save few bytes in the spaces
> > > but then I would just argue to use \t rather than fixed string length.
> > ohh, I misread the code. It tries to emulate the width formater. But is
> > this really necessary? Do we know about any tools doing a fixed string
> > parsing?
> 
> I don't, but it's proc and all the output formatting
> shouldn't be changed.
> 
> Appended to is generally OK, but whitespace changed is
> not good.

OK fair enough, I will
-       seq_write(m, s, 16);
+       seq_puts(m, s);

because smaps needs more than 16 chars and export it in
fs/proc/internal.h

will retest and repost.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

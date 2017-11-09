Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 021A0440CD7
	for <linux-mm@kvack.org>; Thu,  9 Nov 2017 07:19:35 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id u132so8980846ita.0
        for <linux-mm@kvack.org>; Thu, 09 Nov 2017 04:19:34 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id l28si5844818iod.88.2017.11.09.04.19.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 09 Nov 2017 04:19:33 -0800 (PST)
Subject: Re: [PATCH 1/5] mm,page_alloc: Update comment for last second allocation attempt.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1510138908-6265-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20171108145039.tdueguedqos4rpk5@dhcp22.suse.cz>
	<201711091945.IAD64050.MtLFFQOOSOFJHV@I-love.SAKURA.ne.jp>
	<20171109113040.77gapoevxszejyfm@dhcp22.suse.cz>
In-Reply-To: <20171109113040.77gapoevxszejyfm@dhcp22.suse.cz>
Message-Id: <201711092119.BJH69746.OFMOQFOLVtSFHJ@I-love.SAKURA.ne.jp>
Date: Thu, 9 Nov 2017 21:19:24 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, aarcange@redhat.com, hannes@cmpxchg.org

Michal Hocko wrote:
> > So, I believe that the changelog is not wrong, and I don't want to preserve
> > 
> >   keep very high watermark here, this is only to catch a parallel oom killing,
> >   we must fail if we're still under heavy pressure
> > 
> > part which lost strong background.
> 
> I do not see how. You simply do not address the original concern Andrea
> had and keep repeating unrelated stuff.

What does "address the original concern Andrea had" mean?
I'm still thinking that the original concern Andrea had is no longer
valid in the current code because precondition has changed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

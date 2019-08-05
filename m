Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 633D8C0650F
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 23:29:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1B92F2070D
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 23:29:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1B92F2070D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A7C3F6B0005; Mon,  5 Aug 2019 19:29:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A2D166B0006; Mon,  5 Aug 2019 19:29:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 91C2F6B0007; Mon,  5 Aug 2019 19:29:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5E84B6B0005
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 19:29:36 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id 91so47076019pla.7
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 16:29:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=vKWrayXFZ0ABKwATpCplSqPGXqVb2iymV08sdIv5btw=;
        b=aQNHxs2m7GPOdxXLobNBlvozbZ9/mo6sxxa+4x7la5gzRONQBf3C7/HnMYBQNiLu/x
         563t3B/cVpkv58lzS77KqT6Jz+tdGPWQKYInGolaornhuI/JLbzqoz6iJc+TizVuBSrs
         oJ8EtpOf37SNYOA/xMMAO5rjmKnLK02Jp1YLjE/fBbzkmy8jZimD9Ijf2jW0eLlwR6Nc
         4LPCD1DUwlUZcTXuzUz4zWnNIuUrd0kcqnV4IytVn2DGfW6jc0vW4VbhUJOP0qriQzoi
         XpwbyW/VDkU7KudF9f3kcMn14JEQCvK6WnoZYdC95yPStXFQSdgxKYCiikIYStzL/sMT
         A8rQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: APjAAAXjJEgQ7l7819p1XhBP1I5xssMb6fzpkwzps9kw/NPDFtME5JkX
	cWRbPOV2rv3HRe/IbMYdhQIjO43oeFquALMsytfH04KKv5Kh5AybAot7WNxNvbea7Hrx2BHAtYg
	IgnuG6KDLPe5NvtLu4fe7pskqIy34fIoimULfA0XONFxrPef4yMTGD+3Iv88dNwU=
X-Received: by 2002:a17:902:2be8:: with SMTP id l95mr200811plb.231.1565047775996;
        Mon, 05 Aug 2019 16:29:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyXTbGlaTnobNCtpGBL5Q7Npf8GVgZeXReCuiK82iherfzvP3ZmxNXjlomAeLHAqAVq0IOO
X-Received: by 2002:a17:902:2be8:: with SMTP id l95mr200781plb.231.1565047775227;
        Mon, 05 Aug 2019 16:29:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565047775; cv=none;
        d=google.com; s=arc-20160816;
        b=eEY9aTce7Dzkc9KK5WsuKOoJjR3ItXcsTi3akcyg5uPuRtRJ3slPKqnKP7dYr5td3M
         nyAASO7fuPcPtlfWnoh+YglV+06Cha8bXNFr6c2DLa5a3wdKZQYglapi3bFMNTES3Io7
         1tZ97/MI05YzSa9MZWk+lm6IzN3Mf3mbHhnev7rbhKEXf0YQkRylQFVHKYPsCdiEzMjO
         OKF8J0k8TnN44ddcDVe4yiBlCif/SY70mCwpCJEl+w9Glr9ZD0k5NAt2jDLb2wn2xUKR
         WbRy2yLdthJqFbVr0LYlEH8AN0RH+spoB2Vij90FfIgE5c0ObACiT/mzwSXev8ZnIfg0
         9fpw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=vKWrayXFZ0ABKwATpCplSqPGXqVb2iymV08sdIv5btw=;
        b=RBBtsXJsU19tMp6dArlGjN//SQTpE1LR2s6yphYxBU59hm3mgkAERrfZdvs/Op8aT5
         /WFwCxKy63nPTcNOr4gzfddcaM5TZLUqOi3P9ixPwfGYvNrddw1+hZ15vbrxQOdpCH8z
         5LfZ/0eevFKuTra7fWYnlDxUFMPt39tvha97gBEvVvOlhs7qBbmx3z/5HXsWAiILmwhL
         1lmJIjCv2TMvS+iB1KneLFgdVnOgzkE+LaDzzu5k/wPZgqs5EmwrVpD9lgChVvxKmNEx
         hQGOAZuUBz86dpTmfMBnJtafgNk/8jG6DFKPCNljrqXO6tu5uraAijMYeSVbJGeneTq4
         FqiQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from mail104.syd.optusnet.com.au (mail104.syd.optusnet.com.au. [211.29.132.246])
        by mx.google.com with ESMTP id c5si46435307pfr.25.2019.08.05.16.29.34
        for <linux-mm@kvack.org>;
        Mon, 05 Aug 2019 16:29:35 -0700 (PDT)
Received-SPF: neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=211.29.132.246;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from dread.disaster.area (pa49-181-167-148.pa.nsw.optusnet.com.au [49.181.167.148])
	by mail104.syd.optusnet.com.au (Postfix) with ESMTPS id A535A43F3EA;
	Tue,  6 Aug 2019 09:29:33 +1000 (AEST)
Received: from dave by dread.disaster.area with local (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1humOw-0005NL-B6; Tue, 06 Aug 2019 09:28:26 +1000
Date: Tue, 6 Aug 2019 09:28:26 +1000
From: Dave Chinner <david@fromorbit.com>
To: Brian Foster <bfoster@redhat.com>
Cc: linux-xfs@vger.kernel.org, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 14/24] xfs: tail updates only need to occur when LSN
 changes
Message-ID: <20190805232826.GZ7777@dread.disaster.area>
References: <20190801021752.4986-1-david@fromorbit.com>
 <20190801021752.4986-15-david@fromorbit.com>
 <20190805175325.GD14760@bfoster>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190805175325.GD14760@bfoster>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Optus-CM-Score: 0
X-Optus-CM-Analysis: v=2.2 cv=D+Q3ErZj c=1 sm=1 tr=0 cx=a_idp_d
	a=gu9DDhuZhshYSb5Zs/lkOA==:117 a=gu9DDhuZhshYSb5Zs/lkOA==:17
	a=jpOVt7BSZ2e4Z31A5e1TngXxSK0=:19 a=kj9zAlcOel0A:10 a=FmdZ9Uzk2mMA:10
	a=20KFwNOVAAAA:8 a=7-415B0cAAAA:8 a=R7Qwm1BfGGpM9eJvQfgA:9
	a=6B-GerW_oyLF8bKe:21 a=dzTEmkwG1hCzpxrX:21 a=CjuIK1q_8ugA:10
	a=biEYGPWJfzWAr4FL6Ov7:22
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 05, 2019 at 01:53:26PM -0400, Brian Foster wrote:
> On Thu, Aug 01, 2019 at 12:17:42PM +1000, Dave Chinner wrote:
> > From: Dave Chinner <dchinner@redhat.com>
> > 
> > We currently wake anything waiting on the log tail to move whenever
> > the log item at the tail of the log is removed. Historically this
> > was fine behaviour because there were very few items at any given
> > LSN. But with delayed logging, there may be thousands of items at
> > any given LSN, and we can't move the tail until they are all gone.
> > 
> > Hence if we are removing them in near tail-first order, we might be
> > waking up processes waiting on the tail LSN to change (e.g. log
> > space waiters) repeatedly without them being able to make progress.
> > This also occurs with the new sync push waiters, and can result in
> > thousands of spurious wakeups every second when under heavy direct
> > reclaim pressure.
> > 
> > To fix this, check that the tail LSN has actually changed on the
> > AIL before triggering wakeups. This will reduce the number of
> > spurious wakeups when doing bulk AIL removal and make this code much
> > more efficient.
> > 
> > XXX: occasionally get a temporary hang in xfs_ail_push_sync() with
> > this change - log force from log worker gets things moving again.
> > Only happens under extreme memory pressure - possibly push racing
> > with a tail update on an empty log. Needs further investigation.
> > 
> > Signed-off-by: Dave Chinner <dchinner@redhat.com>
> > ---
> 
> Ok, this addresses the wakeup granularity issue mentioned in the
> previous patch. Note that I was kind of wondering why we wouldn't base
> this on the l_tail_lsn update in xlog_assign_tail_lsn_locked() as
> opposed to the current approach.

Because I didn't think of it? :)

There's so much other stuff in this patch set I didn't spend a
lot of time thinking about other alternatives. this was a simple
code transformation that did what I wanted, and I went on to burning
brain cells on other more complex issues that needs to be solved...

> For example, xlog_assign_tail_lsn_locked() could simply check the
> current min item against the current l_tail_lsn before it does the
> assignment and use that to trigger tail change events. If we wanted to
> also filter out the other wakeups (as this patch does) then we could
> just pass a bool pointer or something that returns whether the tail
> actually changed.

Yeah, I'll have a look at this - I might rework it as additional
patches now the code is looking at decisions based on LSN rather
than if the tail log item changed...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com


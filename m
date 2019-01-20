Return-Path: <SRS0=a6Xk=P4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2CCE4C282C2
	for <linux-mm@archiver.kernel.org>; Sun, 20 Jan 2019 20:21:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A516220880
	for <linux-mm@archiver.kernel.org>; Sun, 20 Jan 2019 20:21:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="wFXz6VS4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A516220880
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 07B438E0003; Sun, 20 Jan 2019 15:21:10 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 028DA8E0001; Sun, 20 Jan 2019 15:21:09 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E81278E0003; Sun, 20 Jan 2019 15:21:09 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id C13888E0001
	for <linux-mm@kvack.org>; Sun, 20 Jan 2019 15:21:09 -0500 (EST)
Received: by mail-yb1-f198.google.com with SMTP id d15so2316020ybk.12
        for <linux-mm@kvack.org>; Sun, 20 Jan 2019 12:21:09 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=OEpEYG/0P2v/J4M7joVpRo9Cq+8rhRHs87h/EEaaWhM=;
        b=ufCiSwdNo6W5SvPmzY+3Uok7RgpbUPJCbR+wuXKQborgUBzjLZs8ZzkT22oNVmUKUm
         poT89H12gs0vFFP1dF7OWMlzZeUu9cIIYf+9Eirb5emi4C2gBLe7VXVzUs1Dv3gqSIAb
         RsGfRLpEOcjxU+lMKwyMU2Vtv52STo9EGE2lRarbxPnk8AyfIbgZiNcODgKczFSHKyVv
         rNxifQeffzT1ddqSypQixQ53Mh77YiTs/mluEJU1/f3/24tk6dWeiK81OqbYJ92bCWov
         a0+ffn9+ypTJa2EhQsQm9mN3hXiKTZkAIyRM9Ly+eJrpHhk5dDO63AYWSpd08BSAp1ma
         cYBg==
X-Gm-Message-State: AJcUukdn8LlGshEhNIIxBydezeyAHBCAifetC4mjTu1VwkronLc2JBQh
	M6gCmINHEvVr/ieUL+WrbaedQSQGA1X7yAX1hM8Clzl4uSFTxr4vFg2BmCh/SIElyZCi0vfCu73
	uDLHmXN/2KRJKtJ2+SU/8r231ErAjb1eMUidr+xdxZic2pHBeXdOe+AxHaGStnpAcm/7C9nrOz7
	u1enqMkQ73fp4ru44+nHrzMFbTn7EHZwKjoED+8n5zeLn0eiOvzqA2syCyxEVFfeokaBeLLq1LG
	XCfAbEDcfVKQuHq1zKS6pzIg64mNd+g3n+BKaS4qS0AFKW94k/lckSZji12aHT5MjDaHF9t0XSi
	u3wSwWI5XxjQGguSxYw2qgACDCW2kn6Z7KR3tJ5QV0ru59W0w+8F5gehIdQ8uSUnHv7bUp0mGt0
	B
X-Received: by 2002:a25:38c9:: with SMTP id f192mr15454763yba.64.1548015669460;
        Sun, 20 Jan 2019 12:21:09 -0800 (PST)
X-Received: by 2002:a25:38c9:: with SMTP id f192mr15454733yba.64.1548015668768;
        Sun, 20 Jan 2019 12:21:08 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548015668; cv=none;
        d=google.com; s=arc-20160816;
        b=IZcXoLx1KAFyZTHRR+Fjs97yrVggYOJF5PsgcAetX6TtRZi1AjsvkqQcVKHAnh0iNt
         XEFwdrV4xNHgwg7JEpB44hTrV6g7D5A8PbuTj2veWd8kkkXJKBgbByx3pRIslenT6lcy
         8GZinD1t2cM9vIIHM0kCFNCxyDvYyEXybSH6WIGW3qlLn0JEIKfSfGpdIGAHTq1hA2F3
         PbfWWq9Izz9ZxSTZCl8Oq2FINe9nqerjYXV/q9DPhOQottCfKco425dWYwvUJv4PDpQQ
         /YBKNztP8ljzS9gko+W5IVCefUX91eOJzQyAMUnat716WZ+DaiXQt/czxFgawnDFWlxM
         sJFw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=OEpEYG/0P2v/J4M7joVpRo9Cq+8rhRHs87h/EEaaWhM=;
        b=GlVXN90DuIlVmaTgpvSv1Wskljkvfd9k6hzGH/uI1/D/0L0j0WK0Lq5ybWj/d8Jm+n
         SRGh0GJt72GmtberZpoi9mmgkHPM9j2u8b7zz8KsjzE+f3Irm3MWFWewWtgKvrcXHD17
         3UAaXwtpl9FHIVkYQFTvSB7fltEtPDuIqMztDboC3bUEjKGYWbqQ8nES3AQWWEv+Go9Z
         xpmKvyxXmHdPjw+5nDqXsSbza0NrXUQAesCwi7wRpLkN4Fido7S7UYJOl6cl6WHPS+Gt
         zOLkcMbwpvanswQQ6AxfyPegPod4t8lumAgBfCUDSg8hCgBwUZoxVh0R5otZRa3983Wa
         IiTQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=wFXz6VS4;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c3sor4623755ybi.206.2019.01.20.12.21.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 20 Jan 2019 12:21:08 -0800 (PST)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=wFXz6VS4;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=OEpEYG/0P2v/J4M7joVpRo9Cq+8rhRHs87h/EEaaWhM=;
        b=wFXz6VS4TmhgouhKBWxlxWByBoXZkf2HrzTbE8WN+Dj7vO9iNqt2PlNf79wXHK6K7t
         DqkIk4JyhQKnE6i7KrzX9ckrklJya/+NOLgw6TcbN3fdRLrm5B+opnxsMvyCNI3qESWz
         UasD7zjHsyPwMupwmGDJay/h1cV6OK0mht750/xWv2LLUKRdkwDJcfxBocsHdXWpi4Vx
         RH+dYE8wwc8HwH/iNVsBkP+2C0kdSGi+BA8lOoFFNJL+D+QNBabJ/OP8FMyz9SjTC0ar
         WKpzWQD1y0jIZg6taiGQavg38enlOwwjUjSU5BeCv4Du/5BFak3bl7t3TBnPL6d8fybZ
         qlww==
X-Google-Smtp-Source: ALg8bN4Lc5AT3/6z9ICm7STuaFDqZ6qlHNK6fPVkuyjZ6PjVk+EDgjzdCnz979HSopmOCPxFgAo2eCAoW6/FLGjpCD8=
X-Received: by 2002:a25:5d7:: with SMTP id 206mr14246404ybf.164.1548015668260;
 Sun, 20 Jan 2019 12:21:08 -0800 (PST)
MIME-Version: 1.0
References: <20190119005022.61321-1-shakeelb@google.com> <20190119015843.GB15935@castle.DHCP.thefacebook.com>
In-Reply-To: <20190119015843.GB15935@castle.DHCP.thefacebook.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Sun, 20 Jan 2019 12:20:57 -0800
Message-ID:
 <CALvZod6zRy69bHoXvEWED28OFZ8u4o8JBAL7nyjKMmUjBb5n4w@mail.gmail.com>
Subject: Re: [RFC PATCH] mm, oom: fix use-after-free in oom_kill_process
To: Roman Gushchin <guro@fb.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, 
	David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, 
	"linux-mm@kvack.org" <linux-mm@kvack.org>, 
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190120202057.WXptPj7iaKnjOC2hxQGS2BnbG8AdZsVddymq1xLsLpA@z>

On Fri, Jan 18, 2019 at 5:58 PM Roman Gushchin <guro@fb.com> wrote:
>
> Hi Shakeel!
>
> >
> > On looking further it seems like the process selected to be oom-killed
> > has exited even before reaching read_lock(&tasklist_lock) in
> > oom_kill_process(). More specifically the tsk->usage is 1 which is due
> > to get_task_struct() in oom_evaluate_task() and the put_task_struct
> > within for_each_thread() frees the tsk and for_each_thread() tries to
> > access the tsk. The easiest fix is to do get/put across the
> > for_each_thread() on the selected task.
>
> Please, feel free to add
> Reviewed-by: Roman Gushchin <guro@fb.com>
> for this part.
>

Thanks.

> >
> > Now the next question is should we continue with the oom-kill as the
> > previously selected task has exited? However before adding more
> > complexity and heuristics, let's answer why we even look at the
> > children of oom-kill selected task? The select_bad_process() has already
> > selected the worst process in the system/memcg. Due to race, the
> > selected process might not be the worst at the kill time but does that
> > matter matter? The userspace can play with oom_score_adj to prefer
> > children to be killed before the parent. I looked at the history but it
> > seems like this is there before git history.
>
> I'd totally support you in an attempt to remove this logic,
> unless someone has a good example of its usefulness.
>
> I believe it's a very old hack to select children over parents
> in case they have the same oom badness (e.g. share most of the memory).
>
> Maybe we can prefer older processes in case of equal oom badness,
> and it will be enough.
>
> Thanks!

I am thinking of removing the whole logic of selecting children.

Shakeel


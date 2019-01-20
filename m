Return-Path: <SRS0=a6Xk=P4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1F2A1C282C2
	for <linux-mm@archiver.kernel.org>; Sun, 20 Jan 2019 20:23:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C0D7520880
	for <linux-mm@archiver.kernel.org>; Sun, 20 Jan 2019 20:23:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Ovavreme"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C0D7520880
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6E1CE8E0004; Sun, 20 Jan 2019 15:23:18 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 668D28E0001; Sun, 20 Jan 2019 15:23:18 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 50A378E0004; Sun, 20 Jan 2019 15:23:18 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1CC588E0001
	for <linux-mm@kvack.org>; Sun, 20 Jan 2019 15:23:18 -0500 (EST)
Received: by mail-yw1-f70.google.com with SMTP id x64so10230977ywc.6
        for <linux-mm@kvack.org>; Sun, 20 Jan 2019 12:23:18 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=uyipLOZTSIwpZWsR1TcE0z4tQjeXZYKEV1wzcg4NrdU=;
        b=fkpfLm3ba9ajxb3W5ZKbumgvzwdwT4nT+bXWEunVVXQ+106VYCd9qg/fgVBz/ICUBv
         kL82e5R6ulopBVNflLU4Ljr7fCJcGxs2WFY0315BmDFaYv8MAVM7qRjn14+4p+Rs04ZQ
         HYGdppZt0NNpARqiCtV53K6vTdxucOl5giMev7PQ7eUtLj3p0POayR3y98KHV/xx7A7J
         bGcvcVRYItCDz/1c0XkUK4+8CYrJOJViygnMhL5nnIZypfn3bk3eqGBKOG/5YSkhxYXG
         nDDq+sD7/EziM5R5ThwA+/BK6HOmBHMl+X4usaWs1Uk9Ma1tYGQObBovFiOYep6eTw9M
         UnEg==
X-Gm-Message-State: AJcUukdISGRyvJToQn0Y5Oc49eJHbvVzuJwY6rWsJPTEnKF60ZAT4oHK
	U//h6s3nYbdZl2s8eivbVufze4Tv8g7yFTltF8TqIE/AA3uZZkOf5k/1Lk06fLaXOI8zD2WU3xW
	bRgadXGgDfvoRJsyx+GFtUfq0gjdk4CMHhf3kiGmO/8XjSiahOhyblU/NfgK+OFERKNE6WGbzOc
	0OonxvWUpIGNrwoUS3Ak35e4/ApHquEYVXFpsKQydaCtWw1+3Y/XxNc/jNsbDowccWFrbXLVtw1
	NfxdJBnviTQAH5qrqigaY5TciAaJcCyGej1ZIpLceDiBPz6zNi0Yw5g1c+6z8yYl4xc0zN4GhoD
	RxJf2MVeeNKbcQDQZDDkj3g8QFdU6xnJq6VjvswEA+/WaD7NHqtG2xlcZOi/JKCvnKBifuCs070
	/
X-Received: by 2002:a81:de09:: with SMTP id k9mr26185481ywj.384.1548015797858;
        Sun, 20 Jan 2019 12:23:17 -0800 (PST)
X-Received: by 2002:a81:de09:: with SMTP id k9mr26185467ywj.384.1548015797414;
        Sun, 20 Jan 2019 12:23:17 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548015797; cv=none;
        d=google.com; s=arc-20160816;
        b=w45/E1JDbLNQYg6EqquhVh0SWFRtyewR1gdlTENmkELo9HLBiNlDyqRs/ZyIKXBwPn
         lmEUP/5TlhtKjtcxc/En6C1wn3fsq4FNNIfk99ssaeAxhhNEwA/L7XXKT1Yh/Phsws3m
         kch4bfY+cnfMYSplbaONppWgP151f0nwosSJD1kfZBvuudu5EvscCeQRnZbq96xe3qLK
         zALabBT/NadU466L+/xJSmAsw8+nXGvSr/n7OFOPqvlo9F6WHPKKKrjBNnF67GuCcekF
         AfMURGudREZZi3vNwx5VDv7s6o3YzZG4hkzAyh87EX8FK5PbS0LyqO8iZTrlLP0haE/n
         iYqA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=uyipLOZTSIwpZWsR1TcE0z4tQjeXZYKEV1wzcg4NrdU=;
        b=VeKqvLAVCdvGe9VIbul95RVoILzRAPrz/pLz7fU3InYF0D6QC34W7+bk/Kg9DhINdz
         U+MjppOt6eiMvlhsdttksiqJ2ZoQgocZ0o0F5b+S3p5YZEpmfiXUBV2eRcvPrvtcu62J
         Uzw/ofJw7ynnrM7Hff1S/D8UCYRRcBt4IYovnunC3tJThr2srCbAy6ZQ5heLU7FVD9DK
         QeRWdc46oVoW8adRTJZ4VKzUbc46rFmWsdhSDSDvjAWC+1xUrdEKr5DORdcurgKczz+9
         AusitoZ0h19eIw3xQZiUR9SOxzT+4ufz0N/4PCHMH4DelOYzN2UmH5cf9bIdZUwB9l0a
         3i3A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Ovavreme;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d4sor1905332ywm.164.2019.01.20.12.23.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 20 Jan 2019 12:23:17 -0800 (PST)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Ovavreme;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=uyipLOZTSIwpZWsR1TcE0z4tQjeXZYKEV1wzcg4NrdU=;
        b=Ovavreme06i/tytbU8X7EJC4RV8sMcflD5xhosuyrSWqXc5eM8szEctbmKg9M8LNKO
         aGWQ/xCrNFp00v4VVDGlrSp5ZJdOv6vieT/xlAUKbKPx2yN1vNDJ4iIxj5U936gukCoY
         U9GgQD2k1/pm7VBpzCy0Pe2TCP+E8h22TCV01Fy/em6ASXf5FXqEWUh1YfPaHys/CMq1
         RGaGlIbSDi2TTl6ckosGRJIH3lHT83h1ZzX5z67li1hUGBhnx+A3/slKkvkMPZnCGMg+
         UfjYti0gPSaUYxN1VhlPkjC4XW9A36VerlF7d4Tk9cGFLaTLRlwo8tOika7BfzZhp5MZ
         WT7A==
X-Google-Smtp-Source: ALg8bN7duwdDk5JK1h87DBVWJL+DtD+PdtVzIgEpXIJiCrqL5BteFdBGwjM7HQJUFjBIQLleYVSCz88/LiMRLWbUtB4=
X-Received: by 2002:a81:60c4:: with SMTP id u187mr25686411ywb.345.1548015796908;
 Sun, 20 Jan 2019 12:23:16 -0800 (PST)
MIME-Version: 1.0
References: <20190119005022.61321-1-shakeelb@google.com> <02f74c47-4f35-3d59-f767-268844cb875e@i-love.sakura.ne.jp>
In-Reply-To: <02f74c47-4f35-3d59-f767-268844cb875e@i-love.sakura.ne.jp>
From: Shakeel Butt <shakeelb@google.com>
Date: Sun, 20 Jan 2019 12:23:06 -0800
Message-ID:
 <CALvZod4h7ouNE7p2ouTix9uK3XLUvP6UYNDPEkR-y5PZRJRDnw@mail.gmail.com>
Subject: Re: [RFC PATCH] mm, oom: fix use-after-free in oom_kill_process
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, 
	David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Roman Gushchin <guro@fb.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190120202306.jfZpRUQaMa3SnpuckfITDcnewp97tGtWVS98EHubSB0@z>

On Fri, Jan 18, 2019 at 7:35 PM Tetsuo Handa
<penguin-kernel@i-love.sakura.ne.jp> wrote:
>
> On 2019/01/19 9:50, Shakeel Butt wrote:
> > On looking further it seems like the process selected to be oom-killed
> > has exited even before reaching read_lock(&tasklist_lock) in
> > oom_kill_process(). More specifically the tsk->usage is 1 which is due
> > to get_task_struct() in oom_evaluate_task() and the put_task_struct
> > within for_each_thread() frees the tsk and for_each_thread() tries to
> > access the tsk. The easiest fix is to do get/put across the
> > for_each_thread() on the selected task.
>
> Good catch. p->usage can become 1 while printk()ing a lot at dump_header().
>
> > @@ -981,6 +981,13 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
> >        * still freeing memory.
> >        */
> >       read_lock(&tasklist_lock);
> > +
> > +     /*
> > +      * The task 'p' might have already exited before reaching here. The
> > +      * put_task_struct() will free task_struct 'p' while the loop still try
> > +      * to access the field of 'p', so, get an extra reference.
> > +      */
> > +     get_task_struct(p);
> >       for_each_thread(p, t) {
> >               list_for_each_entry(child, &t->children, sibling) {
> >                       unsigned int child_points;
> > @@ -1000,6 +1007,7 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
> >                       }
> >               }
> >       }
> > +     put_task_struct(p);
>
> Moving put_task_struct(p) to after read_unlock(&tasklist_lock) will reduce
> latency of a write_lock(&tasklist_lock) waiter.
>
> >       read_unlock(&tasklist_lock);
> >
> >       /*
> >
>
> By the way, p->usage is already 1 implies that p->mm == NULL due to already
> completed exit_mm(p). Then, process_shares_mm(child, p->mm) might fail to
> return true for some of children. Not critical but might lead to unnecessary
> oom_badness() calls for child selection. Maybe we want to use same logic
> __oom_kill_process() uses (i.e. bail out if find_task_lock_mm(p) failed)?

Thanks for the review. I am thinking of removing the whole children
selection heuristic for now.

Shakeel


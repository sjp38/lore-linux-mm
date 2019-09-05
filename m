Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3A8EDC00306
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 17:43:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 08A6021848
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 17:43:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="tm3lWKag"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 08A6021848
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 97EAA6B0277; Thu,  5 Sep 2019 13:43:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 92F6E6B0278; Thu,  5 Sep 2019 13:43:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8474A6B0279; Thu,  5 Sep 2019 13:43:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0222.hostedemail.com [216.40.44.222])
	by kanga.kvack.org (Postfix) with ESMTP id 6675A6B0277
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 13:43:42 -0400 (EDT)
Received: from smtpin09.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 12747180AD7C3
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 17:43:42 +0000 (UTC)
X-FDA: 75901589484.09.door11_3d5d34a05c858
X-HE-Tag: door11_3d5d34a05c858
X-Filterd-Recvd-Size: 5481
Received: from mail-io1-f68.google.com (mail-io1-f68.google.com [209.85.166.68])
	by imf44.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 17:43:41 +0000 (UTC)
Received: by mail-io1-f68.google.com with SMTP id x4so6613735iog.13
        for <linux-mm@kvack.org>; Thu, 05 Sep 2019 10:43:41 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=rc/+YGfLUH9jkcuM4RyWN0/LC7MBLhEbb07n7jnHO2w=;
        b=tm3lWKagI89vD+eLi7AXE8oD+HI62AAnfaWnXsUq9NyLp5VlO2gP+7z0HI8FIMTtI6
         sKzk+mOcSfwqJbuyTG1BKDzHx4w5qzzjmNvzjjGGht2pEOPADoMAOobLKh+2Fso4bGF6
         LToEQee7VsrLi2YWLJ5FlwEzxZRSSkXwDJMuWf51o++bndrEm0NoZbMFkljKB5o+yYMe
         NPyWpU0Zn1CGHTGXE3PFhBlso3mA9QmaAiVF4zoiIGTaD4dHWxtX1T68njZ+N+HEPnM5
         MFIBf55iiiyOoB4fdquLw+XijgdWREOtGC1GD97Nt8kItvLcexGylq5cB+/8uvKqaPKx
         tKYg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=rc/+YGfLUH9jkcuM4RyWN0/LC7MBLhEbb07n7jnHO2w=;
        b=BA9Hmwn/KDAhcZxwQTOlmVWPnQtCYv069g482Cu3H8G4uMJbMtaNfzDGuAgrRoAcXe
         qps88RJfqWYsTa6sSEyOwPYk35KDYhQO+FKiyU6qB+KWRtUHrTsRfLd/J9hgru1+znEe
         vgRIJDPms+Libp24yd7CGdLCjhbzwWZBUxxhfRtFHqFvuLnFA0ceMA2NWjIbV1Pu5b8e
         dk6ypu9gqvwpShIrIIMl8Tz3JVvHXODHJYKL3cYJsg9zD3TavK3RfcnvpChlFplekHly
         VQbE/V0NC6NHMUaA5TpDBZT7Wg5HOxcwy03YRZnuMdQJxSTiUZXcrZKT4/pXJDzQLqfR
         9T9Q==
X-Gm-Message-State: APjAAAVtg8CtzjHJ2JKbvumo0K5OkJbWzAJn0rfcAyZRcfbvOPQscnV0
	5iQLzBg17AUpNYGd33xq4c5rfXz2cJVtTPpfX4a2Ag==
X-Google-Smtp-Source: APXvYqwhnxgpgM61no8/EsHbUjHOlH+IoePtyBgQYgqo09A3H0gvTrKuRdjYc0u2d24lPAWQr0rRZBdB9G1xOjZY9YU=
X-Received: by 2002:a6b:bc47:: with SMTP id m68mr5651748iof.70.1567705420697;
 Thu, 05 Sep 2019 10:43:40 -0700 (PDT)
MIME-Version: 1.0
References: <20190903200905.198642-1-joel@joelfernandes.org>
 <20190904084508.GL3838@dhcp22.suse.cz> <20190904153258.GH240514@google.com>
 <20190904153759.GC3838@dhcp22.suse.cz> <20190904162808.GO240514@google.com>
 <20190905144310.GA14491@dhcp22.suse.cz> <CAJuCfpFve2v7d0LX20btk4kAjEpgJ4zeYQQSpqYsSo__CY68xw@mail.gmail.com>
 <20190905133507.783c6c61@oasis.local.home>
In-Reply-To: <20190905133507.783c6c61@oasis.local.home>
From: Tim Murray <timmurray@google.com>
Date: Thu, 5 Sep 2019 10:43:28 -0700
Message-ID: <CAEe=SxmG4oUBUu88NNyOhPC5weExf=UCzLy_pzwg3+CruqO4Cw@mail.gmail.com>
Subject: Re: [PATCH v2] mm: emit tracepoint when RSS changes by threshold
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Suren Baghdasaryan <surenb@google.com>, Michal Hocko <mhocko@kernel.org>, 
	Joel Fernandes <joel@joelfernandes.org>, LKML <linux-kernel@vger.kernel.org>, 
	Carmen Jackson <carmenjackson@google.com>, Mayank Gupta <mayankgupta@google.com>, 
	Daniel Colascione <dancol@google.com>, Minchan Kim <minchan@kernel.org>, 
	Andrew Morton <akpm@linux-foundation.org>, kernel-team <kernel-team@android.com>, 
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Dan Williams <dan.j.williams@intel.com>, 
	Jerome Glisse <jglisse@redhat.com>, linux-mm <linux-mm@kvack.org>, 
	Matthew Wilcox <willy@infradead.org>, Ralph Campbell <rcampbell@nvidia.com>, 
	Vlastimil Babka <vbabka@suse.cz>, Tom Zanussi <zanussi@kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Sep 5, 2019 at 9:03 AM Suren Baghdasaryan <surenb@google.com> wrote:
> I might misunderstand this but is the issue here actually throttling
> of the sheer number of trace records or tracing large enough changes
> to RSS that user might care about? Small changes happen all the time
> but we are likely not interested in those. Surely we could postprocess
> the traces to extract changes large enough to be interesting but why
> capture uninteresting information in the first place? IOW the
> throttling here should be based not on the time between traces but on
> the amount of change of the traced signal. Maybe a generic facility
> like that would be a good idea?

You want two properties from the tracepoint:

- Small fluctuations in the value don't flood the trace buffer. If you
get a new trace event from a process every time kswapd reclaims a
single page from that process, you're going to need an enormous trace
buffer that will have significant side effects on overall system
performance.
- Any spike in memory consumption gets a trace event, regardless of
the duration of that spike. This tracepoint has been incredibly useful
in both understanding the causes of kswapd wakeups and
lowmemorykiller/lmkd kills and evaluating the impact of memory
management changes because it guarantees that any spike appears in the
trace output.

As a result, the RSS tracepoint in particular needs to be throttled
based on the delta of the value, not time. The very first prototype of
the patch emitted a trace event per RSS counter change, and IIRC the
RSS trace events consumed significantly more room in the buffer than
sched_switch (and Android has a lot of sched_switch events). It's not
practical to trace changes in RSS without throttling. If there's a
generic throttling approach that would work here, I'm all for it; like
Dan mentioned, there are many more counters that we would like to
trace in a similar way.


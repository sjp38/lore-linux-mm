Return-Path: <SRS0=NQQQ=W6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E218FC3A5A2
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 10:23:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 95CEF215EA
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 10:23:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="McEMRcHg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 95CEF215EA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 334BA6B0005; Tue,  3 Sep 2019 06:23:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 30BCD6B0006; Tue,  3 Sep 2019 06:23:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1FB7E6B0008; Tue,  3 Sep 2019 06:23:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0232.hostedemail.com [216.40.44.232])
	by kanga.kvack.org (Postfix) with ESMTP id F1A606B0005
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 06:23:07 -0400 (EDT)
Received: from smtpin05.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 89917180AD802
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 10:23:07 +0000 (UTC)
X-FDA: 75893221614.05.kiss54_1b33542e24d27
X-HE-Tag: kiss54_1b33542e24d27
X-Filterd-Recvd-Size: 9321
Received: from mail-ed1-f67.google.com (mail-ed1-f67.google.com [209.85.208.67])
	by imf04.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 10:23:06 +0000 (UTC)
Received: by mail-ed1-f67.google.com with SMTP id z9so12738859edq.8
        for <linux-mm@kvack.org>; Tue, 03 Sep 2019 03:23:06 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=mime-version:in-reply-to:references:from:date:message-id:subject:to
         :cc;
        bh=YKrCK49IbpE/tWo9s4V6zu4/NE9yBWiQViC1BTTLXGM=;
        b=McEMRcHgW936QcIckWIczpqbHQktibTJpT2jbd6atcBs2nTwkMAot4X9YQPEunTvkG
         tEs1l3Cnsjs//tHaLwDEFvbtaww/5kp7R/vSdceVjLHe6vXPgLQNMn56P79HSQEiizcn
         lzAqBQ02S8KlFfC2AxeysPtw4CJoKwPw/jEZ6qImNkHfhZQadqM3Ma6vipYym9Zf2MLV
         jZiH1o7+QKWj8F5mPT0ivy0LQArBYAAaEqPP6nF93iRuUss1dyEjPKqSklLewZ2O51Sv
         VKvPJnqtY9dIVgH8YbBHIFq4rp3E9muw/rYsEHUYnefPfsmKONZub061eGrba8iR7PSv
         M8mQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:in-reply-to:references:from:date
         :message-id:subject:to:cc;
        bh=YKrCK49IbpE/tWo9s4V6zu4/NE9yBWiQViC1BTTLXGM=;
        b=GB4OEzDoE5ffrN0xmDp7dDWiPwv89ydvBjqasha7k5BuVwlRWC/3F1n2858BfYqPBY
         ixocsLj1gKTHoBNADmgaYFoM6x1GTWIZzLBLSszD16m8ThL+ZJXNe2iR9HXh7UK0pft8
         d/DTgVNv4t5NZ8NHpJ5hoHhTZT7pH3xDzL3Q8qRXjiPWIg2Pj3gs8vBSbh2TNF94XJAT
         Bt4kwMV5afzWif1kSwHC+YIg5XJXPGWzZVs6a0MgpXURncOyVSEUyYgyM48mlymNEEot
         TtfDy6xvME9i5WMYmrt6sKtQJmWSTgIO92GdnT6+HG05pq49LvI5Mzm7Wi0SUeDrGm99
         HNGQ==
X-Gm-Message-State: APjAAAUiYDU4oJIjhaGbDXD08V6Tq6GRJ4grZZe6ytyR147w8GLfeMx5
	BpW3WearDzGXB7t5Sm/Cz3nNW3E3gVkm6N9+XTs7Rg==
X-Google-Smtp-Source: APXvYqyL54OE+M//XNz6vd7wic8b2b6/KAIi0s2k+ewwQzvNspn2B3nLAC11zZoli6HEYZIErx1ARjiveoQl03wfoYY=
X-Received: by 2002:a17:906:4882:: with SMTP id v2mr28459625ejq.100.1567506185462;
 Tue, 03 Sep 2019 03:23:05 -0700 (PDT)
MIME-Version: 1.0
Received: by 2002:a17:906:1e01:0:0:0:0 with HTTP; Tue, 3 Sep 2019 03:23:05
 -0700 (PDT)
X-Originating-IP: [71.184.117.43]
In-Reply-To: <ee0723b0-1a4e-eef3-8833-c2eb034e5d08@suse.cz>
References: <1567177025-11016-1-git-send-email-cai@lca.pw> <6109dab4-4061-8fee-96ac-320adf94e130@gmail.com>
 <1567178728.5576.32.camel@lca.pw> <ee0723b0-1a4e-eef3-8833-c2eb034e5d08@suse.cz>
From: Qian Cai <cai@lca.pw>
Date: Tue, 3 Sep 2019 06:23:05 -0400
Message-ID: <CAG=TAF40zcUAQToxLNa1Yq33xNTN8HcNumxwmCEBkLD6bpTifQ@mail.gmail.com>
Subject: Re: [PATCH] net/skbuff: silence warnings under memory pressure
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, "davem@davemloft.net" <davem@davemloft.net>, 
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, 
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>
Content-Type: multipart/alternative; boundary="0000000000005e3c660591a379c5"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--0000000000005e3c660591a379c5
Content-Type: text/plain; charset="UTF-8"

On Monday, September 2, 2019, Vlastimil Babka <vbabka@suse.cz> wrote:

> On 8/30/19 5:25 PM, Qian Cai wrote:
> > On Fri, 2019-08-30 at 17:11 +0200, Eric Dumazet wrote:
> >>
> >> On 8/30/19 4:57 PM, Qian Cai wrote:
> >>> When running heavy memory pressure workloads, the system is throwing
> >>> endless warnings below due to the allocation could fail from
> >>> __build_skb(), and the volume of this call could be huge which may
> >>> generate a lot of serial console output and cosumes all CPUs as
> >>> warn_alloc() could be expensive by calling dump_stack() and then
> >>> show_mem().
> >>>
> >>> Fix it by silencing the warning in this call site. Also, it seems
> >>> unnecessary to even print a warning at all if the allocation failed in
> >>> __build_skb(), as it may just retransmit the packet and retry.
> >>>
>
> Well, __GFP_NOWARN would save me from explaining this warning to users
> many times. OTOH usually it's an indication that min_free_kbytes should
> be raised to better cope with network traffic.


I think it is just a matter of time that the continuous memory pressure
will trigger the issue again, so raising min_free_kbytes does not sound a
solution in this case.


>
> >>
> >> Same patches are showing up there and there from time to time.
> >>
> >> Why is this particular spot interesting, against all others not adding
> >> __GFP_NOWARN ?
>
> This one is interesting that it's a GFP_ATOMIC allocation triggered by
> incoming packets, and has a fallback mechanism. I don't recall other so
> notoric ones.
>
> >> Are we going to have hundred of patches adding __GFP_NOWARN at various
> points,
> >> or should we get something generic to not flood the syslog in case of
> memory
> >> pressure ?
> >>
> >
> > From my testing which uses LTP oom* tests. There are only 3 places need
> to be
> > patched. The other two are in IOMMU code for both Intel and AMD. The
> place is
> > particular interesting because it could cause the system with floating
> serial
> > console output for days without making progress in OOM. I suppose it
> ends up in
> > a looping condition that warn_alloc() would end up generating more calls
> into
> > __build_skb() via ksoftirqd.
>
> Regardless of this particular allocation, if the reporting itself makes
> the conditions so much worse, then at least some kind of general
> ratelimit would make sense indeed.


There is a ratelimit in warn_alloc(), but that does not help in this case.
It occurs to me it is not the rate of this allocation failure causes the
issue, but rather the possible recursive and pure volume of __build_skb()
is the issue.

--0000000000005e3c660591a379c5
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<br><br>On Monday, September 2, 2019, Vlastimil Babka &lt;<a href=3D"mailto=
:vbabka@suse.cz">vbabka@suse.cz</a>&gt; wrote:<br><blockquote class=3D"gmai=
l_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left=
:1ex">On 8/30/19 5:25 PM, Qian Cai wrote:<br>
&gt; On Fri, 2019-08-30 at 17:11 +0200, Eric Dumazet wrote:<br>
&gt;&gt;<br>
&gt;&gt; On 8/30/19 4:57 PM, Qian Cai wrote:<br>
&gt;&gt;&gt; When running heavy memory pressure workloads, the system is th=
rowing<br>
&gt;&gt;&gt; endless warnings below due to the allocation could fail from<b=
r>
&gt;&gt;&gt; __build_skb(), and the volume of this call could be huge which=
 may<br>
&gt;&gt;&gt; generate a lot of serial console output and cosumes all CPUs a=
s<br>
&gt;&gt;&gt; warn_alloc() could be expensive by calling dump_stack() and th=
en<br>
&gt;&gt;&gt; show_mem().<br>
&gt;&gt;&gt;<br>
&gt;&gt;&gt; Fix it by silencing the warning in this call site. Also, it se=
ems<br>
&gt;&gt;&gt; unnecessary to even print a warning at all if the allocation f=
ailed in<br>
&gt;&gt;&gt; __build_skb(), as it may just retransmit the packet and retry.=
<br>
&gt;&gt;&gt;<br>
<br>
Well, __GFP_NOWARN would save me from explaining this warning to users<br>
many times. OTOH usually it&#39;s an indication that min_free_kbytes should=
<br>
be raised to better cope with network traffic.</blockquote><div><br></div><=
div>I think it is just a matter of time that the continuous memory pressure=
 will trigger the issue again, so raising min_free_kbytes does not sound a =
solution in this case.</div><div>=C2=A0</div><blockquote class=3D"gmail_quo=
te" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex"=
>
<br>
&gt;&gt;<br>
&gt;&gt; Same patches are showing up there and there from time to time.<br>
&gt;&gt;<br>
&gt;&gt; Why is this particular spot interesting, against all others not ad=
ding<br>
&gt;&gt; __GFP_NOWARN ?<br>
<br>
This one is interesting that it&#39;s a GFP_ATOMIC allocation triggered by<=
br>
incoming packets, and has a fallback mechanism. I don&#39;t recall other so=
<br>
notoric ones.<br>
<br>
&gt;&gt; Are we going to have hundred of patches adding __GFP_NOWARN at var=
ious points,<br>
&gt;&gt; or should we get something generic to not flood the syslog in case=
 of memory<br>
&gt;&gt; pressure ?<br>
&gt;&gt;<br>
&gt; <br>
&gt; From my testing which uses LTP oom* tests. There are only 3 places nee=
d to be<br>
&gt; patched. The other two are in IOMMU code for both Intel and AMD. The p=
lace is<br>
&gt; particular interesting because it could cause the system with floating=
 serial<br>
&gt; console output for days without making progress in OOM. I suppose it e=
nds up in<br>
&gt; a looping condition that warn_alloc() would end up generating more cal=
ls into<br>
&gt; __build_skb() via ksoftirqd.<br>
<br>
Regardless of this particular allocation, if the reporting itself makes<br>
the conditions so much worse, then at least some kind of general<br>
ratelimit would make sense indeed.</blockquote><div><br></div><div>There is=
 a ratelimit in warn_alloc(), but that does not help in this case. It occur=
s to me it is not the rate of this allocation failure causes the issue, but=
 rather the possible recursive and pure volume of __build_skb() is the issu=
e.</div>

--0000000000005e3c660591a379c5--


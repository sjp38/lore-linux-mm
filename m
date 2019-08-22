Return-Path: <SRS0=SaVu=WS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 609B9C3A5A1
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 20:07:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C160E21848
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 20:07:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ucr.edu header.i=@ucr.edu header.b="DBKyfV4u"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C160E21848
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=ucr.edu
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1C7466B0354; Thu, 22 Aug 2019 16:07:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 14D9A6B0355; Thu, 22 Aug 2019 16:07:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EE1DA6B0356; Thu, 22 Aug 2019 16:07:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0119.hostedemail.com [216.40.44.119])
	by kanga.kvack.org (Postfix) with ESMTP id C38706B0354
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 16:07:38 -0400 (EDT)
Received: from smtpin13.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 5298052C5
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 20:07:38 +0000 (UTC)
X-FDA: 75851148996.13.jump11_4290e0fb2a43e
X-HE-Tag: jump11_4290e0fb2a43e
X-Filterd-Recvd-Size: 10458
Received: from mx6.ucr.edu (mx6.ucr.edu [138.23.62.71])
	by imf35.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 20:07:37 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple;
  d=ucr.edu; i=@ucr.edu; q=dns/txt; s=selector3;
  t=1566504458; x=1598040458;
  h=mime-version:references:in-reply-to:from:date:message-id:
   subject:to:cc;
  bh=twSsK6uJ8+BthqLTkPzTPldCXDcG+gRxl7zt0qSxAFc=;
  b=DBKyfV4u6cpmyUCMZO0yzKCLGXDcxmeU6Fe/V+S3KzfdbOx2WFxD+yMU
   U92VTiQaY9r5TB81TBimqtkpx9qp9dICqTIZtwhYqt/JRjE+/cu1yCku6
   7ckppsxc0PZKApg/g+YwA1WTos1Gr5EPH0jcd5gHttIALVzMZ798VBuAV
   Z5Fp2lfQ9m4cQg/5h+JGgdRk7SecPwLdSLxCBaRqHH5E7vKJNlWdAioWt
   3Inf8t1ARttAYkeIQE9wTKdniZrHJ0GMQ4nkq4eVtnC3Rdqj7rAwe0j9w
   j22Vg7p2QiTnDuLx5EZZXzv/Vh0UMrZsBwiSD7EcN0GE7B0+wRLxCHcuv
   w==;
IronPort-SDR: cz9Svg3giGD3jZ4KMgQdgFLe5tyjQD+CeSMrBqngIYSgS0e82jflP1E01E4iQjMbgVqwYCHFLo
 S+pTMEiK1rReTp5P1UrMb+EXc+ZGdpHICPgvCDD0cCAek2IciGUob7kLEG+nw+IdaMD3zeJWPW
 VvfGFtu+TeSUuvUnn1kv5VT8myg1A473QZtcbFmx6hEAAfknSLdxoO/X6Jrfa4R2IcfcaKDgqf
 gfpmRa0tUPvLGY3Xv6ocimLDCfBb7mZPEWqnUnKPxNiAUld/OabDkOBCzUMmxjGI4GH/VIhVL3
 CCo=
IronPort-PHdr: =?us-ascii?q?9a23=3Act9RQhPbO7ioiWueE5Ml6mtUPXoX/o7sNwtQ0K?=
 =?us-ascii?q?IMzox0Lfr7rarrMEGX3/hxlliBBdydt6sezbOK7euxCCQp2tWoiDg6aptCVh?=
 =?us-ascii?q?sI2409vjcLJ4q7M3D9N+PgdCcgHc5PBxdP9nC/NlVJSo6lPwWB6nK94iQPFR?=
 =?us-ascii?q?rhKAF7Ovr6GpLIj8Swyuu+54Dfbx9HiTagf79+Ngi6oArQu8UZhYZvLrs6xw?=
 =?us-ascii?q?fUrHdPZ+lY335jK0iJnxb76Mew/Zpj/DpVtvk86cNOUrj0crohQ7BAAzsoL2?=
 =?us-ascii?q?465MvwtRneVgSP/WcTUn8XkhVTHQfI6gzxU4rrvSv7sup93zSaPdHzQLspVz?=
 =?us-ascii?q?mu87tnRRn1gyocKTU37H/YhdBxjKJDoRKuuRp/w5LPYIqIMPZyZ77Rcc8GSW?=
 =?us-ascii?q?ZEWMtaSi5PDZ6mb4YXAOUBM+RXoYnzqVUNsBWwGxWjCfj1xTNUnHL7x7E23/?=
 =?us-ascii?q?gjHAzAwQcuH8gOsHPRrNjtNqgSUOG0zKnVzTXEcvhZ2jf955LJchs8pvyNXb?=
 =?us-ascii?q?NxccrLxkkuCw/JkludpJf4PzyJzOQBqXaU4Pd9Ve+2jWMstgJ/oiC3y8sylo?=
 =?us-ascii?q?XEgpgZx1PE+Clj3oo5Od61RFRmbdOgEpZdsTyROZFsTcM4WW5ovT43yrgBuZ?=
 =?us-ascii?q?GmYicH0I8nxxvDa/yfdIiI/w7jWP6RIThmgHJlf6qyhxOo/kihzu3wT8200F?=
 =?us-ascii?q?RXoiZcnNnAq3QA2h7J5siITft9+Uih2TKR2AzJ9u5EJkU0mbLaK54n3LEwio?=
 =?us-ascii?q?IevVrfEiLygkn7j6+bel869uS06OnreKjqq5ueOoNsjwHxKKUumsixAeQiNQ?=
 =?us-ascii?q?gOWnCW+OS91b3j50L5QalGguE4n6TCrZDVOd4bqrSnDABIz4Yv8wy/ACu+0N?=
 =?us-ascii?q?QEgXkHK0pIeBaGj4jvJlHPL+n0DfK6g1m3kzdr2erJMaHiApnXKXjDirjhLv?=
 =?us-ascii?q?5B7Bt5yQEzxNQXx5VfCbZJdPfzXUTys/TbAwU/PgjyxPzoXoZTzIQbDFOOEK?=
 =?us-ascii?q?+EN+vgsVaJrrY+MemFZddN4x7gIOJj6vLz2yxq0WQBdLWkiMNEIEuzGe5rdg?=
 =?us-ascii?q?DAOSLh?=
X-IronPort-Anti-Spam-Filtered: true
X-IronPort-Anti-Spam-Result: =?us-ascii?q?A2FOAQCY9V5dgMXQVdFkHAEBAQQBAQc?=
 =?us-ascii?q?EAQGBZ4EWgkAzKoQggR2NZIIPkwtlhx8BCAEBAQ4vAQGEPwKCYCM4EwIJAQE?=
 =?us-ascii?q?FAQEBAQEGBAEBAhABAQkNCQgnhUKCOikBgmcBAQEBAgESEQRSBQsJAgQHAwo?=
 =?us-ascii?q?qAgIiEgEFARwGEyKEfA8FkA2PDIEDPIskfzOIdwEIDIFJEoEii2+CF4ERgxI?=
 =?us-ascii?q?+hA2DQoJYBIEuAQEBlDWVdQEGAgGCCxSMHIghG5hKLaVeDyGBRoF6MxolfwZ?=
 =?us-ascii?q?ngU6Ceo4tIjCKRoJNBQEB?=
X-IPAS-Result: =?us-ascii?q?A2FOAQCY9V5dgMXQVdFkHAEBAQQBAQcEAQGBZ4EWgkAzK?=
 =?us-ascii?q?oQggR2NZIIPkwtlhx8BCAEBAQ4vAQGEPwKCYCM4EwIJAQEFAQEBAQEGBAEBA?=
 =?us-ascii?q?hABAQkNCQgnhUKCOikBgmcBAQEBAgESEQRSBQsJAgQHAwoqAgIiEgEFARwGE?=
 =?us-ascii?q?yKEfA8FkA2PDIEDPIskfzOIdwEIDIFJEoEii2+CF4ERgxI+hA2DQoJYBIEuA?=
 =?us-ascii?q?QEBlDWVdQEGAgGCCxSMHIghG5hKLaVeDyGBRoF6MxolfwZngU6Ceo4tIjCKR?=
 =?us-ascii?q?oJNBQEB?=
X-IronPort-AV: E=Sophos;i="5.64,417,1559545200"; 
   d="scan'208,217";a="72072607"
Received: from mail-lj1-f197.google.com ([209.85.208.197])
  by smtpmx6.ucr.edu with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 22 Aug 2019 13:07:36 -0700
Received: by mail-lj1-f197.google.com with SMTP id b20so1281247ljj.17
        for <linux-mm@kvack.org>; Thu, 22 Aug 2019 13:07:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=zkSbAF9+t+HFpJzf022PyyXVr3D+/DYXnqwcnL7+WpU=;
        b=K31YmoV24uFsJzXLcf8iXpM4iqfewgrW/D+vIAHteXer9jwMHYGc3QuRRX/IJuY2Vb
         KkJf+YdZ4Td2uwBldTSum2fZ6V8cQ9pTooGbtsSMLIjbtO45t7jPLhntwWDjKv8w5r8H
         1cXL2gtkwcPF6VSLRaP4u/RoLj/2ZimrDOTMvl7V4YZvcoRJwLVgaDdQxYVgx2Zw3FGO
         79kqovALahKKppSe8OLQsNBBlKQBK7nHzkRR5OQedKyiJd75PzHiiarolmH6/fNbChir
         YydtB/+72OsyBCcEYKSM+6IE0M9luhRbVnL8McqcV2xU+TiJc8M3v7Wj6IJhy9mkHYDn
         Hnyg==
X-Gm-Message-State: APjAAAWr/ynbsbwrvXsYI562NtJHwK+HWLcLEJmjhKxh2ha1QTAhz9jM
	bYAK1xQSHja4TGmdSldi3dOvNOiBWmbs4YKf22En/HyejZ0HS9GYh3s+lopypAu+nL2Y5j3S678
	F0L7X1oYQx8ireN7dPtSRcWd+ofvg
X-Received: by 2002:a2e:875a:: with SMTP id q26mr647591ljj.107.1566504452432;
        Thu, 22 Aug 2019 13:07:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw70QfpRa07l1GQX4ysDWYmE7rV8wUqR1RV6yq/CgtXa+bkIq8vBHb3xBmS6GjxvEKRX6JHuH0gEZF8S/4rUzo=
X-Received: by 2002:a2e:875a:: with SMTP id q26mr647573ljj.107.1566504452207;
 Thu, 22 Aug 2019 13:07:32 -0700 (PDT)
MIME-Version: 1.0
References: <20190822062210.18649-1-yzhai003@ucr.edu> <20190822070550.GA12785@dhcp22.suse.cz>
In-Reply-To: <20190822070550.GA12785@dhcp22.suse.cz>
From: Yizhuo Zhai <yzhai003@ucr.edu>
Date: Thu, 22 Aug 2019 13:07:17 -0700
Message-ID: <CABvMjLRCt4gC3GKzBehGppxfyMOb6OGQwW-6Yu_+MbMp5tN3tg@mail.gmail.com>
Subject: Re: [PATCH] mm/memcg: return value of the function
 mem_cgroup_from_css() is not checked
To: Michal Hocko <mhocko@kernel.org>
Cc: Chengyu Song <csong@cs.ucr.edu>, Zhiyun Qian <zhiyunq@cs.ucr.edu>, 
	Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org, 
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Content-Type: multipart/alternative; boundary="00000000000069d58c0590ba3d90"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000011, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--00000000000069d58c0590ba3d90
Content-Type: text/plain; charset="UTF-8"

This will happen if variable "wb->memcg_css" is NULL. This case is reported
by our analysis tool.
Since the function mem_cgroup_wb_domain() is visible to the global, we
cannot control caller's behavior.

On Thu, Aug 22, 2019 at 12:06 AM Michal Hocko <mhocko@kernel.org> wrote:

> On Wed 21-08-19 23:22:09, Yizhuo wrote:
> > Inside function mem_cgroup_wb_domain(), the pointer memcg
> > could be NULL via mem_cgroup_from_css(). However, this pointer is
> > not checked and directly dereferenced in the if statement,
> > which is potentially unsafe.
>
> Could you describe circumstances when this would happen? The code is
> this way for 5 years without any issues. Are we just lucky or something
> has changed recently to make this happen?
>
> > Signed-off-by: Yizhuo <yzhai003@ucr.edu>
> > ---
> >  mm/memcontrol.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> >
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 661f046ad318..bd84bdaed3b0 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -3665,7 +3665,7 @@ struct wb_domain *mem_cgroup_wb_domain(struct
> bdi_writeback *wb)
> >  {
> >       struct mem_cgroup *memcg = mem_cgroup_from_css(wb->memcg_css);
> >
> > -     if (!memcg->css.parent)
> > +     if (!memcg || !memcg->css.parent)
> >               return NULL;
> >
> >       return &memcg->cgwb_domain;
> > --
> > 2.17.1
> >
>
> --
> Michal Hocko
> SUSE Labs
>


-- 
Kind Regards,

*Yizhuo Zhai*

*Computer Science, Graduate Student*
*University of California, Riverside *

--00000000000069d58c0590ba3d90
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div dir=3D"ltr"><div dir=3D"ltr"><div dir=3D"ltr">This wi=
ll happen if variable &quot;wb-&gt;memcg_css&quot; is NULL. This case is re=
ported by our analysis tool.</div><div dir=3D"ltr">Since the function mem_c=
group_wb_domain() is visible to the global, we cannot control caller&#39;s =
behavior.</div></div></div></div><br><div class=3D"gmail_quote"><div dir=3D=
"ltr" class=3D"gmail_attr">On Thu, Aug 22, 2019 at 12:06 AM Michal Hocko &l=
t;<a href=3D"mailto:mhocko@kernel.org">mhocko@kernel.org</a>&gt; wrote:<br>=
</div><blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;b=
order-left-width:1px;border-left-style:solid;border-left-color:rgb(204,204,=
204);padding-left:1ex">On Wed 21-08-19 23:22:09, Yizhuo wrote:<br>
&gt; Inside function mem_cgroup_wb_domain(), the pointer memcg<br>
&gt; could be NULL via mem_cgroup_from_css(). However, this pointer is<br>
&gt; not checked and directly dereferenced in the if statement,<br>
&gt; which is potentially unsafe.<br>
<br>
Could you describe circumstances when this would happen? The code is<br>
this way for 5 years without any issues. Are we just lucky or something<br>
has changed recently to make this happen?<br>
<br>
&gt; Signed-off-by: Yizhuo &lt;<a href=3D"mailto:yzhai003@ucr.edu" target=
=3D"_blank">yzhai003@ucr.edu</a>&gt;<br>
&gt; ---<br>
&gt;=C2=A0 mm/memcontrol.c | 2 +-<br>
&gt;=C2=A0 1 file changed, 1 insertion(+), 1 deletion(-)<br>
&gt; <br>
&gt; diff --git a/mm/memcontrol.c b/mm/memcontrol.c<br>
&gt; index 661f046ad318..bd84bdaed3b0 100644<br>
&gt; --- a/mm/memcontrol.c<br>
&gt; +++ b/mm/memcontrol.c<br>
&gt; @@ -3665,7 +3665,7 @@ struct wb_domain *mem_cgroup_wb_domain(struct bd=
i_writeback *wb)<br>
&gt;=C2=A0 {<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0struct mem_cgroup *memcg =3D mem_cgroup_from=
_css(wb-&gt;memcg_css);<br>
&gt;=C2=A0 <br>
&gt; -=C2=A0 =C2=A0 =C2=A0if (!memcg-&gt;css.parent)<br>
&gt; +=C2=A0 =C2=A0 =C2=A0if (!memcg || !memcg-&gt;css.parent)<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return NULL;<br>
&gt;=C2=A0 <br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0return &amp;memcg-&gt;cgwb_domain;<br>
&gt; -- <br>
&gt; 2.17.1<br>
&gt; <br>
<br>
-- <br>
Michal Hocko<br>
SUSE Labs<br>
</blockquote></div><br clear=3D"all"><div><br></div>-- <br><div dir=3D"ltr"=
 class=3D"gmail_signature"><div dir=3D"ltr"><span style=3D"font-size:14px">=
Kind Regards,</span><div style=3D"font-size:14px"><br><div><font face=3D"ar=
ial, helvetica, sans-serif" size=3D"2"><b>Yizhuo Zhai</b></font></div></div=
><div style=3D"font-size:14px"><br></div><div style=3D"font-size:14px"><b>C=
omputer Science, Graduate Student</b></div><div style=3D"font-size:14px"><b=
>University of California, Riverside=C2=A0</b></div></div></div>

--00000000000069d58c0590ba3d90--


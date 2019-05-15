Return-Path: <SRS0=idO3=TP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 99869C04E53
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 20:26:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 46FB82070D
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 20:26:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="SAIOuCey"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 46FB82070D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BCEA46B0007; Wed, 15 May 2019 16:26:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B58536B0008; Wed, 15 May 2019 16:26:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9F78B6B000A; Wed, 15 May 2019 16:26:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6B4F96B0007
	for <linux-mm@kvack.org>; Wed, 15 May 2019 16:26:29 -0400 (EDT)
Received: by mail-oi1-f199.google.com with SMTP id q82so493582oif.7
        for <linux-mm@kvack.org>; Wed, 15 May 2019 13:26:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=CNowSPd6xUM0oSrW52wC5X6N9h9RHW9ouHTqZZOyPB4=;
        b=YIIGdlOl0VyW+fSM1l5OIdUeo67Fk9Iw70V84R8+MkZ9AtELvLUU1CIykxNxunxz8W
         LsTR9++4/TZjFHoak7mbhqsJd+c6mr++XZMC4wWPGjEOIz2+on5a6ApmN0khdXkv5lGr
         NVoqR5WKMFBJxuGBK/2vcn5Kx7UzbsZ6YdLQRYmyR+QAgMHrcQzMvLU9FqUqN8/mE2TC
         zf7R1zqbonx21bgd+gvkaoMU43gLNTIAwgHhE/+JVK1jAIzIAxjlnWqzpLsavYK3YTEs
         JqX6r0mp3/uElCyl/2Br062vvNQshLo4+4i170a6ABFqDFmEyE7XFBD6PjA5/YaAlrHd
         gksw==
X-Gm-Message-State: APjAAAWyk9Ol4oWkLcr62KPfYxBOml9koQntnQAMdgEHmQj9Fb6H9y+L
	CaEYaxDR0X3772uUjDHjtKb27VaVPVDdQZ/qa8CWNSBo2/zGPUCzLmvUC0sh5LbzL9qfdxC2XgQ
	vOqeGTnWJg1DJUZHC5+dC6CfucmuhAAICOhZiGSbmPn0YXE0rCWUg/mUtH8nRAgOMkQ==
X-Received: by 2002:a9d:744d:: with SMTP id p13mr7792785otk.96.1557951989041;
        Wed, 15 May 2019 13:26:29 -0700 (PDT)
X-Received: by 2002:a9d:744d:: with SMTP id p13mr7792740otk.96.1557951988389;
        Wed, 15 May 2019 13:26:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557951988; cv=none;
        d=google.com; s=arc-20160816;
        b=hZ8A8Khz0i0wbNM65bUR3lpbQBBPherag4nCNzeLEJy3oMtkOrwuRxRemytFW7crsQ
         wRAasjgKmSehwCozceB6e3+mt5kJqTu3FzpHxiBUDW/O7fxjGBvxcIajC8bM7j55UU4x
         kv0FCUJfiBtVF/X8Gt2irwTtIyoLR3ZT79AwJJ7Rv+9gNK7idebYWFq3Ql8oK8yMeJ4k
         Ob8QJKM4V+UrgOPD3TFYbeLiRVQLkoTyBjC6R5w0Y0Ud36QpM6NDmLnZQbgnNfG4DvoQ
         IA3vqnSExh/UJDWe4JTww5Wvz6jd8vlU+lNn7l65jOmxBhXDRiK7hKDbqRIBKeb6A0mG
         wPDg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=CNowSPd6xUM0oSrW52wC5X6N9h9RHW9ouHTqZZOyPB4=;
        b=A7LGnMIac5QWM+/KayoOBzPEob/1vTr4G2A0eNRXL3dXPWsKYZIt+o5KD25iWmn/Gm
         vNawK0uhqRVamIPQg9o4mrd1Q4JEUxLmRTqniJ6avgvihTSPsj/JOD6S0GkvdzF9ZNi6
         D3yiBjO8QHP+5BCmzyh6IxP+jlrEUKFCzMubqgiXyVg5ZpxJocNg+R30dhX1WqTKoAyg
         y532DXPfBtNd3wCcXpbsuSyrfF4UoJXXMy981x/3QSTI2wjixIgbuYEte433ZU2kbpji
         lpMh4vVwaZBzz0W5fgd3szB1ZmvJiuVarWidaxTbN2kDCxVTinpNmzVjQg28Hlf0Fps5
         VKsA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=SAIOuCey;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d63sor1427809oia.81.2019.05.15.13.26.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 15 May 2019 13:26:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=SAIOuCey;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=CNowSPd6xUM0oSrW52wC5X6N9h9RHW9ouHTqZZOyPB4=;
        b=SAIOuCey/H4PDGjItNH6MJbpdQ6eVphhRbi02FoQ/YOnoYGxaydqsOYiVIAO/t3q68
         0i+LFQ13vsz1bj8cCiXxLi+GMY0PpVS/n4Tnm/fMII2aHygPYzSJnwoWDtPiIo9XVU4B
         UF+xwmZUZQ0W+oJace3RMwVkn3Iuq8GIugGZdBu4qRRMMPgZWHzuG5COUhU0vp87nTs/
         FG1JFG1PtJ3RikGbUfL/NJErfucnwOSQDnoR242LrP2jVHyNv6FXHEZUgTRCbyr9ydcG
         Lyzzv47sX90bEqpeR7WfOo7msFCsrbGa0h1IuogufITOeuGE2XDwd6+gyOeGA8Z7o+W9
         OqGg==
X-Google-Smtp-Source: APXvYqx3oc7K1TBy0FDWKi5FhWmRYToljSQrlPDbQpttbtlguEoDEhZRGEYR3NAHlPXP6/3HQG4xvypvNp6sEKcLSAk=
X-Received: by 2002:aca:4208:: with SMTP id p8mr8481558oia.105.1557951987781;
 Wed, 15 May 2019 13:26:27 -0700 (PDT)
MIME-Version: 1.0
References: <CAPcyv4he0q_FdqqiXarp0bXjcggs8QZX8Od560E2iFxzCU3Qag@mail.gmail.com>
 <CAHk-=wjvmwD_0=CRQtNs5RBh8oJwrriXDn+XNWOU=wk8OyQ5ew@mail.gmail.com>
 <CAPcyv4hafLUr2rKdLG+3SHXyWaa0d_2g8AKKZRf2mKPW+3DUSA@mail.gmail.com>
 <CAHk-=wiTM93XKaFqUOR7q7133wvzNS8Kj777EZ9E8S99NbZhAA@mail.gmail.com>
 <CAPcyv4hMZMuSEtUkKqL067f4cWPGivzn9mCtv3gZsJG2qUOYvg@mail.gmail.com> <CAHk-=wgnJd_qY1wGc0KcoGrNz3Mp9-8mQFMDLoTXvEMVtAxyZQ@mail.gmail.com>
In-Reply-To: <CAHk-=wgnJd_qY1wGc0KcoGrNz3Mp9-8mQFMDLoTXvEMVtAxyZQ@mail.gmail.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 15 May 2019 13:26:16 -0700
Message-ID: <CAPcyv4g+reM9y+CiGXpxBYMQZ-Yh4LuXDi2530FR0zt3o6J8Hg@mail.gmail.com>
Subject: Re: [GIT PULL] device-dax for 5.1: PMEM as RAM
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, 
	Linux MM <linux-mm@kvack.org>, Dave Hansen <dave.hansen@intel.com>, 
	"Luck, Tony" <tony.luck@intel.com>, Vishal L Verma <vishal.l.verma@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 11, 2019 at 5:08 PM Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> On Mon, Mar 11, 2019 at 8:37 AM Dan Williams <dan.j.williams@intel.com> wrote:
> >
> > Another feature the userspace tooling can support for the PMEM as RAM
> > case is the ability to complete an Address Range Scrub of the range
> > before it is added to the core-mm. I.e at least ensure that previously
> > encountered poison is eliminated.
>
> Ok, so this at least makes sense as an argument to me.
>
> In the "PMEM as filesystem" part, the errors have long-term history,
> while in "PMEM as RAM" the memory may be physically the same thing,
> but it doesn't have the history and as such may not be prone to
> long-term errors the same way.
>
> So that validly argues that yes, when used as RAM, the likelihood for
> errors is much lower because they don't accumulate the same way.

In case anyone is looking for the above mentioned tooling for use with
the v5.1 kernel, Vishal has released ndctl-v65 with the new
"clear-errors" command [1].

[1]: https://pmem.io/ndctl/ndctl-clear-errors.html


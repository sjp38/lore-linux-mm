Return-Path: <SRS0=Igro=TR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DA8BBC04AB4
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 13:00:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 91C6F2087B
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 13:00:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="MFTlhXiT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 91C6F2087B
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1EDDF6B0273; Fri, 17 May 2019 09:00:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 19F446B0274; Fri, 17 May 2019 09:00:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 08E1B6B0275; Fri, 17 May 2019 09:00:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id DE6006B0273
	for <linux-mm@kvack.org>; Fri, 17 May 2019 09:00:30 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id 11so6184718ywt.12
        for <linux-mm@kvack.org>; Fri, 17 May 2019 06:00:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=a1Yjx9G9Kz0lAC4Y66vJlqEx5sunA3IfD/gaYb8FYZg=;
        b=uCLDAOQLAAFWMKlVXC1Gp4I9U3GbmrZD+lVnWLLd0PEuDEDVf8CYfKFxtOi8p0anoy
         VnR6ImM2ao89/1ESyRfL/mE7dIyqdGU18H7cEgcJ1gZaHukXrU2e5wYqhWoQDL6M/x+Z
         ktzuLMYySpw3uJL2BEajQaDn9vwVpKCL2HesCEj+lRVXTPuwONZlx9FmI042KtbcWb7j
         P3tN4EOxySHiot+VaTjFHzO/QkAVLyAxGYsjpURpX9xj0c0k3oOWkpYm4SpA6z//m/nl
         kN8RHMClXTGdJMCunTEd65EFGs+L1tMzS+PiEqLRN6EcC52Cbw4GZJOxlboshBscxBtg
         09/Q==
X-Gm-Message-State: APjAAAU2zq2WrIpMBn5fJyWknhXcHZWcWQDlyjSufdfkwcfyNo2L3NhR
	69OdYw3rNOrZKDTMnoQGxogama9BgYp7RoXuTNI7/HMNadPMd+F2UuJ5D+k0ay43GqJqoVwyu2O
	3bK00v6nOxS+5ivldmj/exBp3PGf46PvFBh/kDyjl4QXGbm0hCSTTTYv41iZrhBKguw==
X-Received: by 2002:a25:283:: with SMTP id 125mr27256023ybc.286.1558098030659;
        Fri, 17 May 2019 06:00:30 -0700 (PDT)
X-Received: by 2002:a25:283:: with SMTP id 125mr27255979ybc.286.1558098030043;
        Fri, 17 May 2019 06:00:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558098030; cv=none;
        d=google.com; s=arc-20160816;
        b=ETKzrlTYEB1DHBmd5oy8SxZGJgGBzO1AeVxXL2cwcWbjg+SuPIr7WtKr2HdqLsvqev
         E6tDcDvAxXiUwEmhNXrp6N4Y4v39fszt40zW9CgGIX7oRjac5lP1eMgdzZ2E/kLyY+FT
         8O9TkR+/LD61gR1DNvFwb14gelD5uIi+YnkaWp9XW6/UAt+j8Qa6lqIixh6QOAgXTJA1
         C8c9Xlqq0BbbX1BaIBkp/sGPuT6B247gNpdz4lgYUPT46xHipsHrUkfaXcQHAmN8Ic/Q
         ilvNIScVidNtO1CKSoPdHUv5KTfLDW8/yThD51GTL4KqHOaaPuxsAJiYFYcJheTc3CGs
         ykTw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=a1Yjx9G9Kz0lAC4Y66vJlqEx5sunA3IfD/gaYb8FYZg=;
        b=0xlqyYWLC7kG236YV9354FQAEMYJ1ou7hk59KhNnXmuoF3IzG3v/PVEJqAFEzS6wnk
         NTUfMdwZRVEoLo2J5imocyU39G6N3Na/5jCfz2wf0RTWPiwqV7m02i1T0BgoyNzIruwz
         GQYMkfXuRXFou9OiS9op8lN/SvLrfU9P8uOXxL2SG/U8JtDWCjJba2sKN3+xv7j+MywH
         nO4tdIXSQ7MLcWIjtHTCjmfJeawtCucce8f2tPXLfFtl1CIypvbhTxUwpQkaszHHUhiS
         fv3I2UZlv5W9WP0kCpXrEMG1iEiQsPlmDeYKIeqqDhFu6Visd9yAEaS97djB35N2VcuF
         G/dQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=MFTlhXiT;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z124sor4597592ywb.59.2019.05.17.06.00.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 17 May 2019 06:00:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=MFTlhXiT;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=a1Yjx9G9Kz0lAC4Y66vJlqEx5sunA3IfD/gaYb8FYZg=;
        b=MFTlhXiTud3V1AxxK2rZ5o5zpilyu81HAboG8GjjYlTyRXOAGY+30B+tlGH/9k5QK6
         ooVhXJWOGpXm2w0ayEc3NzoZrx+FCfNv3raolPiPxi58q6nIgYJEHqWmXEQ5tHS4DwE+
         XsOCMusbwFDKhP1yrjwO7HnGDj5jD0D1p+Ucw/m3scGKT60QjoxsSnvXR1dccOZkZd4+
         M+YQD+Ry0gv1Weoql/hAMb9EaW5YLu2LFgL/SIFFNrykQ4cF8aSCtrf3E4fqvlbwxEyF
         T1rgPtWgEcFYMISlUJW0eKCR4iuLcj8t5EBLTXGlj9WTNGMhVWKTVgg4GhaV/5XfrNit
         Wc6A==
X-Google-Smtp-Source: APXvYqy3YDHyKFiBF5MyJ5W3EVNngA6meDmel8s+TXbnXyXy5tgKxYfP/M3jWgeR37q9rAiyPOS/NvUTJrKLZl67WCA=
X-Received: by 2002:a81:5ec3:: with SMTP id s186mr27762147ywb.308.1558098029521;
 Fri, 17 May 2019 06:00:29 -0700 (PDT)
MIME-Version: 1.0
References: <20190212224542.ZW63a%akpm@linux-foundation.org>
 <20190213124729.GI4525@dhcp22.suse.cz> <20190516175655.GA25818@cmpxchg.org>
 <20190516180932.GA13208@dhcp22.suse.cz> <20190516193943.GA26439@cmpxchg.org> <20190517123310.GI6836@dhcp22.suse.cz>
In-Reply-To: <20190517123310.GI6836@dhcp22.suse.cz>
From: Shakeel Butt <shakeelb@google.com>
Date: Fri, 17 May 2019 06:00:18 -0700
Message-ID: <CALvZod6xErQ3AA+9oHSqB2bqtK9gKk4T0iPoGPkufBiJALko1Q@mail.gmail.com>
Subject: Re: + mm-consider-subtrees-in-memoryevents.patch added to -mm tree
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, 
	mm-commits@vger.kernel.org, Tejun Heo <tj@kernel.org>, Roman Gushchin <guro@fb.com>, 
	Dennis Zhou <dennis@kernel.org>, Chris Down <chris@chrisdown.name>, 
	cgroups mailinglist <cgroups@vger.kernel.org>, Linux MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 17, 2019 at 5:33 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Thu 16-05-19 15:39:43, Johannes Weiner wrote:
> > On Thu, May 16, 2019 at 08:10:42PM +0200, Michal Hocko wrote:
> > > On Thu 16-05-19 13:56:55, Johannes Weiner wrote:
> > > > On Wed, Feb 13, 2019 at 01:47:29PM +0100, Michal Hocko wrote:
> [...]
> > > > > FTR: As I've already said here [1] I can live with this change as long
> > > > > as there is a larger consensus among cgroup v2 users. So let's give this
> > > > > some more time before merging to see whether there is such a consensus.
> > > > >
> > > > > [1] http://lkml.kernel.org/r/20190201102515.GK11599@dhcp22.suse.cz
> > > >
> > > > It's been three months without any objections.
> > >
> > > It's been three months without any _feedback_ from anybody. It might
> > > very well be true that people just do not read these emails or do not
> > > care one way or another.
> >
> > This is exactly the type of stuff that Mel was talking about at LSFMM
> > not even two weeks ago. How one objection, however absurd, can cause
> > "controversy" and block an effort to address a mistake we have made in
> > the past that is now actively causing problems for real users.
> >
> > And now after stalling this fix for three months to wait for unlikely
> > objections, you're moving the goal post. This is frustrating.
>
> I see your frustration but I find the above wording really unfair. Let me
> remind you that this is a considerable user visible change in the
> semantic and that always has to be evaluated carefuly. A change that would
> clearly regress anybody who rely on the current semantic. This is not an
> internal implementation detail kinda thing.
>
> I have suggested an option for the new behavior to be opt-in which
> would be a regression safe option. You keep insisting that we absolutely
> have to have hierarchical reporting by default for consistency reasons.
> I do understand that argument but when I weigh consistency vs. potential
> regression risk I rather go a conservative way. This is a traditional
> way how we deal with semantic changes like this. There are always
> exceptions possible and that is why I wanted to hear from other users of
> cgroup v2, even from those who are not directly affected now.
>
> If you feel so stronly about this topic and the suggested opt-in is an
> absolute no-go then you are free to override my opinion here. I haven't
> Nacked this patch.
>
> > Nobody else is speaking up because the current user base is very small
> > and because the idea that anybody has developed against and is relying
> > on the current problematic behavior is completely contrived. In
> > reality, the behavior surprises people and causes production issues.
>
> I strongly suspect users usually do not follow discussions on our
> mailing lists. They only come up later when something breaks and that
> is too late. I do realize that this makes the above call for a wider
> consensus harder but a lack of upstream bug reports also suggests that
> people do not care or simply haven't noticed any issues due to way how
> they use the said interface (maybe deeper hierarchies are not that
> common).
>

I suspect that FB is the only one using cgroup v2 in production and
others (data center) users are still evaluating/exploring. Also IMHO
the cgroup v2 users are on the bleeding edge. As new cgroup v2
features and controllers are added, the users either switch to latest
kernel or backport. That might be the reason no one objected. Also
none of the distribution has defaulted to v2 yet, so, not many
transparent v2 users yet.

Shakeel


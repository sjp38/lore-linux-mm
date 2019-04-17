Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DCA3DC282DA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 11:36:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9AED620656
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 11:36:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="kMbCFC+e"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9AED620656
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3787C6B0003; Wed, 17 Apr 2019 07:36:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 326866B0006; Wed, 17 Apr 2019 07:36:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 23F5B6B0007; Wed, 17 Apr 2019 07:36:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id CA64F6B0003
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 07:36:33 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id f42so7366794edd.0
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 04:36:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=eKzmZNT13+qker03LiNcwHRJhLqfn2RV0qJqGvu7EY4=;
        b=XF7pTODHqOFfum1drgPtt0x1pzJJVlLdqxt0KWSKYJaJfyI8muTIunhmSn6/S+2UVi
         lMEZgCe1yanIGyOlPYjEFDMNWpOdzfRBbfJadSvnsxwZC8EBm1mXVChOgi4LnovhVkXi
         lCX1xOb3F5ltMUkv5jZK2ceN5s7CNHVAOsfxXYZ59ffRfkpQ81rj+AXMr24YJa1fWLkY
         MqAiJ7XhGlNXBfxvhKq9udeZcnW1TwbnUfS+OzMDw+BtCeOa54ILh7TtndrfTBzwO+jv
         PeUwAUxxsqueSf3df6JQo2azc3i7yee0ENNDyTuQjr9uxf3BgzoYMCzdPBbPq/Td4wgh
         pTkQ==
X-Gm-Message-State: APjAAAXBTc5QOpG4EeBwnedGxukW+7lef4wx3H+Qwk6m9J5Sl9ozUyRG
	S5eH1mDKAi2jfMem4O7W3fpkD13C37D5TckS2nGsKOGlje2Znwb+I7KE8Wgje7PivCv4uNpL9F5
	vhMnvCxlnoWlWHXiZakzje/JtoaKEqxi+GiRBRMmrLl+QiwkIWfpP3Cy734R/Mvj/cQ==
X-Received: by 2002:a17:906:5c7:: with SMTP id t7mr47860650ejt.129.1555500993232;
        Wed, 17 Apr 2019 04:36:33 -0700 (PDT)
X-Received: by 2002:a17:906:5c7:: with SMTP id t7mr47860602ejt.129.1555500992214;
        Wed, 17 Apr 2019 04:36:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555500992; cv=none;
        d=google.com; s=arc-20160816;
        b=yHx1b08KYNcsRIv36iwLlu4QCFo7lINIk27P1UXw9Ebqe1JBYAtxaFbEkIkuDMvVrL
         fUqPEZB33JW2s18u8IC8cFeIA3RgJc4l52dwX1bd7wXjxmJ2RrQUvUHNL3lsATGUoWyG
         sNcSv+AhDjYxrYWBEgrgBOaqTmvwVbJbnG+DzeRR1sMQD5hY3qZlim0LIMu4aj6Zhamo
         7zC2ke+AJXTBmcth85ly77GI4jhV9CG4oEcU8FV1jiOfcCBEl+OGExQptNq/N1FQZmKn
         CmdcP+ElyLRgA7CtKOI21aRVz6ODMuXOWC8//nMEa2u6Z9nf6YQ0nBdN8LYZHVbYdqjQ
         Trrg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=eKzmZNT13+qker03LiNcwHRJhLqfn2RV0qJqGvu7EY4=;
        b=pHNVURjS8vizDUVAJw8ZX7+g2rwqzCu5m3q/KaSjCSmC7tdMDkKDN5PeHFjeMwwBMu
         JFdc1oW8tP0FdGU9GvLqXZ2AKEXqbcskJVahbt7X9HIIRzrbTCcxxKVrBKyEf48Pis4c
         rrWFDJUhr3s97YW6IMyO75udO5Uo50DH7DR3u/RVExs/zSJilLUi7p6uUn+AxhkWNmrt
         HdMw3OLD4wqwUG6yaCFl1ld7iaLjYzExdELh75QNSDJndRKSc2mv/YnSxOJOyyH1ImqB
         O2WbXas5tAI6oqxW67MLtDpJRsgNEZQkaVDZziEIBUOn6YwwFBcaUSxGJCQy/axeXExZ
         j00A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=kMbCFC+e;
       spf=pass (google.com: domain of huangzhaoyang@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=huangzhaoyang@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l13sor8666121edn.10.2019.04.17.04.36.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Apr 2019 04:36:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of huangzhaoyang@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=kMbCFC+e;
       spf=pass (google.com: domain of huangzhaoyang@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=huangzhaoyang@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=eKzmZNT13+qker03LiNcwHRJhLqfn2RV0qJqGvu7EY4=;
        b=kMbCFC+eUYXJoI5dYtIWxJ5wK3/tha36syWzU3Rv+YAe3oJ6BkXSk74Q3VESpj80dR
         rwS4k7J7wGEez1GYJIQtaNJcA8/AIEyQMKWheQtXWv5ow8aDkodVTPmMYIqKlv61FFQX
         80PmR/Yoddis22cMFJor3N49+ErK3zzL18v3JifdHl06pgVZv3Y90lMwQoeR8omnz3rO
         63/jkMGT/TOAn2CeUmPSyGR5c8Sf+pqUna0EBTsd6UTaaYJTkMFUPTXvAnBkqOkUTsIN
         kXFV1i0kj/vB5ViXpaDufDydMr9N3On2/0gLJCPdeQCZDh3O70/pzzX8ZENA0CXK+mzl
         rwgQ==
X-Google-Smtp-Source: APXvYqyM0mpjUAGmFS7Qeq6tF9uIsM7K3XKsvzCmSbrsHUAUkohN+1Lb9WVOy6rYXPhbo36xcd4zlVfyWMp5FotVF6A=
X-Received: by 2002:a50:ac2b:: with SMTP id v40mr19049674edc.54.1555500991965;
 Wed, 17 Apr 2019 04:36:31 -0700 (PDT)
MIME-Version: 1.0
References: <1555487246-15764-1-git-send-email-huangzhaoyang@gmail.com>
 <CAGWkznFCy-Fm1WObEk77shPGALWhn5dWS3ZLXY77+q_4Yp6bAQ@mail.gmail.com>
 <CAGWkznEzRB2RPQEK5+4EYB73UYGMRbNNmMH-FyQqT2_en_q1+g@mail.gmail.com> <20190417110615.GC5878@dhcp22.suse.cz>
In-Reply-To: <20190417110615.GC5878@dhcp22.suse.cz>
From: Zhaoyang Huang <huangzhaoyang@gmail.com>
Date: Wed, 17 Apr 2019 19:36:21 +0800
Message-ID: <CAGWkznH6MjCkKeAO_1jJ07Ze2E3KHem0aNZ_Vwf080Yg-4Ujbw@mail.gmail.com>
Subject: Re: [RFC PATCH] mm/workingset : judge file page activity via timestamp
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, 
	Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, 
	Zhaoyang Huang <zhaoyang.huang@unisoc.com>, Roman Gushchin <guro@fb.com>, 
	Jeff Layton <jlayton@redhat.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>, Pavel Tatashin <pasha.tatashin@soleen.com>, 
	Johannes Weiner <hannes@cmpxchg.org>, Matthew Wilcox <willy@infradead.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

sorry for the confusion. What I mean is the basic idea doesn't change
as replacing the refault criteria from refault_distance to timestamp.
But the detailed implementation changed a lot, including fix bugs,
update the way of packing the timestamp, 32bit/64bit differentiation
etc. So it makes sense for starting a new context.

On Wed, Apr 17, 2019 at 7:06 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Wed 17-04-19 18:55:15, Zhaoyang Huang wrote:
> > fix one mailbox and update for some information
> >
> > Comparing to http://lkml.kernel.org/r/1554348617-12897-1-git-send-email-huangzhaoyang@gmail.com,
> > this commit fix the packing order error and add trace_printk for
> > reference debug information.
> >
> > For johannes's comments, please find bellowing for my feedback.
>
> OK, this suggests there is no strong reason to poset a new version of
> the patch then. Please do not fragment discussion and continue
> discussing in the original email thread until there is some conclusion
> reached.
>
> Thanks!
> --
> Michal Hocko
> SUSE Labs


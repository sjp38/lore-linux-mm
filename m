Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C2F03C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 10:49:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7DB5E2183F
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 10:49:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="VNcte+ku"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7DB5E2183F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0C2328E0003; Thu, 28 Feb 2019 05:49:24 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 047DE8E0001; Thu, 28 Feb 2019 05:49:23 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E2B568E0003; Thu, 28 Feb 2019 05:49:23 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id B851A8E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 05:49:23 -0500 (EST)
Received: by mail-it1-f200.google.com with SMTP id x87so3953017ita.1
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 02:49:23 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=RB/VMG7u60T8INZFCvvnDZ76dB6R/WBXxH/BFSAbgTc=;
        b=oYKBjkljtiQcOCrUCgyAqrlaGe/6ilcAm3ziMXqL7qCToVNY4hGNoFqwbPV6pPsciD
         q1flFIKUhfRuqaXzyJhbQ7QmZ+u70H9NQUXeY+wcCmEV3VcX+UKjSfSJr+J3VGOOjri8
         N1jXDmDPDA1hQOl22NJMb3fVqMR+PjLh5OzBWyLHRIoQT88p/SK9TSLtOI+XVJw3HZuf
         XK0OZ2v5lETaNeUDhUXtX9oM1X4uFV5N580CKUIc3FP/aJpNb+9R2+GoAgNPTlEjEB1P
         mrRwA8CFPIXOJCVB3biE+bjTVDJa6T81vkaBpePO9G0SBJlS1JtJ/ExmcvnoJRFVAhuS
         6DaQ==
X-Gm-Message-State: APjAAAX7O16x5MS4KzdBKg8NQ+HKA4S7is4hni+pBSrrRH+u9WTo+s2+
	0OkIOvpMixfqsKX4OzrMyJDRjUZb6POtD6708Kn+6a4pgaUmLDKj/2Dq9QmS3O+jZ1i57SaFuXt
	euKBmI5jQ+JNz7IC9dXcUnh+p4wkpDl8bj135iHCl3NIdzI0fqgAYSTQTSQV8zOj59n94fYayZa
	0UhazA0YsAfzD2AejDur6zbIN3JeNYlHFRORpHWR2uwmPNs3ZC2P3S3596DfLFndleUw5ZPHb3e
	eTnmpAqH72tsLSCXrneNzzFkRQizWMWy/SgYtPu/OwSQD5g8qcx7U5PcMqam9Yyayw0DQCFN0ZU
	TP1BIq7PUERRV3plHBUdRVIvRiq8+2eqFnSB616MpTygPpYhyXpdwEyVdxJeRmRWOoHj0UkOsOV
	B
X-Received: by 2002:a6b:d319:: with SMTP id s25mr4801602iob.158.1551350963523;
        Thu, 28 Feb 2019 02:49:23 -0800 (PST)
X-Received: by 2002:a6b:d319:: with SMTP id s25mr4801577iob.158.1551350962815;
        Thu, 28 Feb 2019 02:49:22 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551350962; cv=none;
        d=google.com; s=arc-20160816;
        b=Xsk/otv+463S4CWnCCTrPeAxH2+nbmiIQfNJjLjDGuRuFnr+MRUp5cXJTM2NajtjX+
         +oaJC24qWUKbERoQ6b3FDo2xeqO05mZ4960hiJauslhg4Huj3mBOaHgrN3eB5XjziUmX
         W5OrXI8/MEsNWyxxn6sz4MQwKiojB3AIuVC7a4Ou410bRcgxna6LrZicKzIhGRvkZNpP
         vs6r7vnIRi9oaZaJ9lglSyp1c2gKPGa5PDWSuslPOVToIwcL+dbc4VoDC/O3f4QxVPoM
         NQBARAIJSgCBhkNI24y9+Qc2bhL66G89MKrKJwco0Qcf+GKm/17NSMq+MqKCiCbKny1Q
         Vg1g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=RB/VMG7u60T8INZFCvvnDZ76dB6R/WBXxH/BFSAbgTc=;
        b=FezvR3SAjIPtV5LWdK+qiv3PSh+o3EKA+FjYC3jUzMzu1BDtYCFi4HgG1D/A6Wa5NQ
         uaKYt369j5x9YlGKhR/ys0Yej648wXeR4drNHNvy8u+JvkwjTGznKH2LtdnBDmqz/18f
         72wNrbcLuF11U6BZiLscShzDcI5MpDMmrjM1G360O0PItfPcHwX0K7zbnR9KV2HMrX5L
         OvvgDn0Fcce400wMjzd21+6dpNb4SgIyzlEzhqOtTQhC8/r0H2rSh0va1hGUjet1J7Ie
         OMydujBJORS5SQf6UFYDNG2xjOvpJIFb19cxrXSYCCoPzozqKpvUD7ie1sWp4oWbcvKb
         Jh2g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=VNcte+ku;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p16sor9891863ios.4.2019.02.28.02.49.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Feb 2019 02:49:22 -0800 (PST)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=VNcte+ku;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=RB/VMG7u60T8INZFCvvnDZ76dB6R/WBXxH/BFSAbgTc=;
        b=VNcte+kudUAgGFlzPWV/+negJWt9tSI822DcsA6XvaRIzZ/0OCn7ShZj9+GbHnTACW
         vpG9QSjnRZiY4UKJVzb4VtRuKeGhnZzdEz1AjAECKMFOg2ZEk2fSMUaUDiFfEV1TnFHs
         AEvprkZ34cdinNf+bcRpFr1bFAkLVOPWEAkn3UsBil6A/iC+c/WgUu/dRWqdC7F6EOa/
         zEDj6zNCHhC+hY5ork7WJoH2E9Zl39L4P4ZWLVABTyca1uTSVgnRNGVq3/MUgnXAhP2j
         EGYOytwd6Ahcga6jQdCS3Z0dxKX/ctfJahCACWvRg/1Ln/GQhJQPPT6eOST1LTMZ+YW4
         m99A==
X-Google-Smtp-Source: APXvYqyelUV/wLnvoJFHXRX1SlIBCvX7nHv+L8iv3g9+CU7GW2pb83qaNwRo5c5AFlkivX+ls+v+VDrI3r+nbHKMjIY=
X-Received: by 2002:a5d:84c3:: with SMTP id z3mr4836173ior.11.1551350962573;
 Thu, 28 Feb 2019 02:49:22 -0800 (PST)
MIME-Version: 1.0
References: <1551341664-13912-1-git-send-email-laoar.shao@gmail.com>
 <2cf3574c-34f9-ada8-d27c-1ed822031305@suse.cz> <CALOAHbB8veCnu2EvTMhH6dJTOcWmozSE+3sKtX9jXheFtJjQUA@mail.gmail.com>
 <b88ec9aa-4630-353a-955a-3e365d44b5d1@suse.cz>
In-Reply-To: <b88ec9aa-4630-353a-955a-3e365d44b5d1@suse.cz>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Thu, 28 Feb 2019 18:48:46 +0800
Message-ID: <CALOAHbDjT5DwoDoSUYGw3y=KBXMr-AOCD_HwytpKZi__beXCjg@mail.gmail.com>
Subject: Re: [PATCH] mm: vmscan: add tracepoints for node reclaim
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, ktkhai@virtuozzo.com, 
	broonie@kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Linux MM <linux-mm@kvack.org>, 
	shaoyafang@didiglobal.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 28, 2019 at 6:44 PM Vlastimil Babka <vbabka@suse.cz> wrote:
>
> On 2/28/19 11:34 AM, Yafang Shao wrote:
> > On Thu, Feb 28, 2019 at 6:21 PM Vlastimil Babka <vbabka@suse.cz> wrote:
> >>
> >> On 2/28/19 9:14 AM, Yafang Shao wrote:
> >>> In the page alloc fast path, it may do node reclaim, which may cause
> >>> latency spike.
> >>> We should add tracepoint for this event, and also mesure the latency
> >>> it causes.
> >>>
> >>> So bellow two tracepoints are introduced,
> >>>       mm_vmscan_node_reclaim_begin
> >>>       mm_vmscan_node_reclaim_end
> >>>
> >>> Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
> >>> ---
> >>>  include/trace/events/vmscan.h | 48 +++++++++++++++++++++++++++++++++++++++++++
> >>>  mm/vmscan.c                   | 13 +++++++++++-
> >>>  2 files changed, 60 insertions(+), 1 deletion(-)
> >>>
> >>> diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
> >>> index a1cb913..9310d5b 100644
> >>> --- a/include/trace/events/vmscan.h
> >>> +++ b/include/trace/events/vmscan.h
> >>> @@ -465,6 +465,54 @@
> >>>               __entry->ratio,
> >>>               show_reclaim_flags(__entry->reclaim_flags))
> >>>  );
> >>> +
> >>> +TRACE_EVENT(mm_vmscan_node_reclaim_begin,
> >>> +
> >>> +     TP_PROTO(int nid, int order, int may_writepage,
> >>> +             gfp_t gfp_flags, int zid),
> >>> +
> >>> +     TP_ARGS(nid, order, may_writepage, gfp_flags, zid),
> >>> +
> >>> +     TP_STRUCT__entry(
> >>> +             __field(int, nid)
> >>> +             __field(int, order)
> >>> +             __field(int, may_writepage)
> >>
> >> For node reclaim may_writepage is statically set in node_reclaim_mode,
> >> so I'm not sure it's worth including it.
> >>
> >>> +             __field(gfp_t, gfp_flags)
> >>> +             __field(int, zid)
> >>
> >> zid seems wasteful and misleading as it's simply derived by
> >> gfp_zone(gfp_mask), so I would drop it.
> >>
> >
> > I agree with you that may_writepage and zid is wasteful, but I found
> > they are in other tracepoints in this file,
> > so I place them in this tracepoint as well.
>
> I see zid only in kswapd waking tracepoints? That's different kind of
> event.
>

Pls. see mm_vmscan_wakeup_kswapd and  classzone_idx in
mm_vmscan_direct_reclaim_begin_template.

mm_vmscan_direct_reclaim_begin_template:
    "order=%d may_writepage=%d gfp_flags=%s classzone_idx=%d"

mm_vmscan_wakeup_kswapd:
    "nid=%d zid=%d order=%d gfp_flags=%s"








> > Seems we'd better drop them from other tracepoints as well ?
>
> Hmm seems may_writepage in other tracepoints depends on laptop_mode
> which is also a static setting. do_try_to_free_pages() can override it
> due to priority, but that doesn't affect the tracepoints. If they are to
> be dropped, it would be a separate patch though.

OK.

Thanks
Yafang


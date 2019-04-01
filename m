Return-Path: <SRS0=sWz3=SD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5C13FC43381
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 13:24:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E160120870
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 13:24:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E160120870
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 46C9B6B0003; Mon,  1 Apr 2019 09:24:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 445CA6B0008; Mon,  1 Apr 2019 09:24:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 35A846B000A; Mon,  1 Apr 2019 09:24:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 138466B0003
	for <linux-mm@kvack.org>; Mon,  1 Apr 2019 09:24:29 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id p26so9854017qtq.21
        for <linux-mm@kvack.org>; Mon, 01 Apr 2019 06:24:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=KS+1c3Vojzyb+7dVwmo5U26YD3fLjLn9a1tMKJjoS4k=;
        b=TvNUb8MhCme/9fNZ1pmamqHtEmEfxI88dhBie4ik4ye3q0ztYV5xF1Wulx02tA63uI
         0KDh3oxgJQaMPJredIZmcPEmURm6Z1FthTVSPZhhW77VffjEFyYVQ2ay86JjdO+F93mC
         Ei1LspnBlywDTrhkPYUX+poNcDHNqU8zEH/UkG8y+HxdyZ800YYR6FcDio2Oz4V2MMdr
         0DYptJbyY7ca/Gh7x2VYInE8LlDnHZW2ugw0m2V+gsyMYLFcJ9F40BzWvx9uz8E6eow3
         Ab9JBfaA19/K9hv7I0rtfmRKKsa8RjQqwbrgzcqGcEQRR2eyQYznph7//FmLPMuWDMrQ
         MprA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUJi1cIf9F3H18dJPzTAJR4fBQg5Xj5eiv5I0p5ywXyPzSDSUXk
	S/oJzDdojEZiFlYKrFMDIAq+47fOtNOUVo97wkdSwkVNMh2tzqVl/XpjrjEDu/254XrLbDYSY3c
	DEMC39rps8pYX4s/ZOL3ey+cIUUDZFCpj8/F+mB3+6RMOkBpWhzA8z6CWR+bdNaF+RA==
X-Received: by 2002:a37:7602:: with SMTP id r2mr49981131qkc.97.1554125068665;
        Mon, 01 Apr 2019 06:24:28 -0700 (PDT)
X-Received: by 2002:a37:7602:: with SMTP id r2mr49981036qkc.97.1554125067306;
        Mon, 01 Apr 2019 06:24:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554125067; cv=none;
        d=google.com; s=arc-20160816;
        b=AFAeb7DuqYrKeGWP9xbgpuOO+TLSHBCDFUQHe39m+IGXGbivgwkUzHpZlbRSTVPEL9
         E7dg9TZEANFecVhdrjzNopqogtamoey4fN/4b6Ki3oCnYrEMV9iTnvBjwI29XxdB1TRA
         jqlp79E7eUYQbpywtoYkChKNNNpWCvjUq9WFwReavRhiwIy+YQiX191xPTw5jGorYv0f
         TxBI9GGlCKGU5aHX6y2fXZNl2kLBrWWjjVjfMlJVVolZanE+KlsuLNDOLUWy3Tu9BtEo
         FcQH6f1GJae5vF+K1nOxDIfOA4phl7mL+yV60N19X7U7ykMgMqW7DIYtFXNi/ZFv9+v2
         mxdg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=KS+1c3Vojzyb+7dVwmo5U26YD3fLjLn9a1tMKJjoS4k=;
        b=gYhIyjP/6asb2uGqou/1X2mqT2Dd4ya0O56qOl1/0/HFnivCyf/OragkPtGHlfJCVf
         binXeWMGuDeRwmAKwf3SUpmYDFBQpSdmq9hUFnCEjCdEIVMuRD9EKIlE0RSqixHgP6QP
         aE7Hdi4ZrMm4bHTVJO5ItN0viLQCOLh3ZyrzIuw90QgNuXR5ArrIj1oueXi5WIZuyL3z
         LezPo3rx0jTNH6hAeQC59+y2q7fcO+mUEBm/5JFD/zZ5SBzmwiI3Ivps5bFfA7VVvlaJ
         bZmmxXxQMA2tO38xyYsn6BjK/YeCd6fvARhKiW6XOw5uuDmFihpnEZULddMHSRjJ/Qm2
         vmIw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id h24sor5816935qkg.54.2019.04.01.06.24.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 01 Apr 2019 06:24:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqxC6uhAZYJO2uzybFMhDPdKfjq16vwXLlqC7zLTwqXm0B59DECvR1zrYtTN/TVC/JhIYOw1Lw==
X-Received: by 2002:a37:a78b:: with SMTP id q133mr12320217qke.289.1554125066981;
        Mon, 01 Apr 2019 06:24:26 -0700 (PDT)
Received: from redhat.com (pool-173-76-246-42.bstnma.fios.verizon.net. [173.76.246.42])
        by smtp.gmail.com with ESMTPSA id d17sm5201048qtl.43.2019.04.01.06.24.24
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 01 Apr 2019 06:24:26 -0700 (PDT)
Date: Mon, 1 Apr 2019 09:24:18 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: David Hildenbrand <david@redhat.com>
Cc: Nitesh Narayan Lal <nitesh@redhat.com>, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	pbonzini@redhat.com, lcapitulino@redhat.com, pagupta@redhat.com,
	wei.w.wang@intel.com, yang.zhang.wz@gmail.com, riel@surriel.com,
	dodgen@google.com, konrad.wilk@oracle.com, dhildenb@redhat.com,
	aarcange@redhat.com, alexander.duyck@gmail.com
Subject: Re: On guest free page hinting and OOM
Message-ID: <20190401073007-mutt-send-email-mst@kernel.org>
References: <20190329084058-mutt-send-email-mst@kernel.org>
 <f6332928-d6a4-7a75-245d-2c534cf6e710@redhat.com>
 <20190329104311-mutt-send-email-mst@kernel.org>
 <7a3baa90-5963-e6e2-c862-9cd9cc1b5f60@redhat.com>
 <f0ee075d-3e99-efd5-8c82-98d53b9f204f@redhat.com>
 <20190329125034-mutt-send-email-mst@kernel.org>
 <fb23fd70-4f1b-26a8-5ecc-4c14014ef29d@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <fb23fd70-4f1b-26a8-5ecc-4c14014ef29d@redhat.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 01, 2019 at 10:17:51AM +0200, David Hildenbrand wrote:
> On 29.03.19 17:51, Michael S. Tsirkin wrote:
> > On Fri, Mar 29, 2019 at 04:45:58PM +0100, David Hildenbrand wrote:
> >> On 29.03.19 16:37, David Hildenbrand wrote:
> >>> On 29.03.19 16:08, Michael S. Tsirkin wrote:
> >>>> On Fri, Mar 29, 2019 at 03:24:24PM +0100, David Hildenbrand wrote:
> >>>>>
> >>>>> We had a very simple idea in mind: As long as a hinting request is
> >>>>> pending, don't actually trigger any OOM activity, but wait for it to be
> >>>>> processed. Can be done using simple atomic variable.
> >>>>>
> >>>>> This is a scenario that will only pop up when already pretty low on
> >>>>> memory. And the main difference to ballooning is that we *know* we will
> >>>>> get more memory soon.
> >>>>
> >>>> No we don't.  If we keep polling we are quite possibly keeping the CPU
> >>>> busy so delaying the hint request processing.  Again the issue it's a
> >>>
> >>> You can always yield. But that's a different topic.
> >>>
> >>>> tradeoff. One performance for the other. Very hard to know which path do
> >>>> you hit in advance, and in the real world no one has the time to profile
> >>>> and tune things. By comparison trading memory for performance is well
> >>>> understood.
> >>>>
> >>>>
> >>>>> "appended to guest memory", "global list of memory", malicious guests
> >>>>> always using that memory like what about NUMA?
> >>>>
> >>>> This can be up to the guest. A good approach would be to take
> >>>> a chunk out of each node and add to the hints buffer.
> >>>
> >>> This might lead to you not using the buffer efficiently. But also,
> >>> different topic.
> >>>
> >>>>
> >>>>> What about different page
> >>>>> granularity?
> >>>>
> >>>> Seems like an orthogonal issue to me.
> >>>
> >>> It is similar, yes. But if you support multiple granularities (e.g.
> >>> MAX_ORDER - 1, MAX_ORDER - 2 ...) you might have to implement some sort
> >>> of buddy for the buffer. This is different than just a list for each node.
> > 
> > Right but we don't plan to do it yet.
> 
> MAX_ORDER - 2 on x86-64 seems to work just fine (no THP splits) and
> early performance numbers indicate it might be the right thing to do. So
> it could be very desirable once we do more performance tests.
> 
> > 
> >> Oh, and before I forget, different zones might of course also be a problem.
> > 
> > I would just split the hint buffer evenly between zones.
> > 
> 
> Thinking about your approach, there is one elementary thing to notice:
> 
> Giving the guest pages from the buffer while hinting requests are being
> processed means that the guest can and will temporarily make use of more
> memory than desired. Essentially up to the point where MADV_FREE is
> finally called for the hinted pages.

Right - but that seems like exactly the reverse of the issue with the current
approach which is guest can temporarily use less memory than desired.

> Even then the guest will logicall
> make use of more memory than desired until core MM takes pages away.

That sounds more like a host issue though. If it wants to
it can use e.g. MAD_DONTNEED.

> So:
> 1) Unmodified guests will make use of more memory than desired.

One interesting possibility for this is to add the buffer memory
by hotplug after the feature has been negotiated.
I agree this sounds complex.

But I have an idea: how about we include the hint size in the
num_pages counter? Then unmodified guests put
it in the balloon and don't use it. Modified ones
will know to use it just for hinting.


> 2) Malicious guests will make use of more memory than desired.

Well this limitation is fundamental to balloon right?
If host wants to add tracking of balloon memory, it
can enforce the limits. So far no one bothered,
but maybe with this feature we should start to do that.

> 3) Sane, modified guests will make use of more memory than desired.
>
> Instead, we could make our life much easier by doing the following:
> 
> 1) Introduce a parameter to cap the amount of memory concurrently hinted
> similar like you suggested, just don't consider it a buffer value.
> "-device virtio-balloon,hinting_size=1G". This gives us control over the
> hinting proceess.
> 
> hinting_size=0 (default) disables hinting
> 
> The admin can tweak the number along with memory requirements of the
> guest. We can make suggestions (e.g. calculate depending on #cores,#size
> of memory, or simply "1GB")

So if it's all up to the guest and for the benefit of the guest, and
with no cost/benefit to the host, then why are we supplying this value
from the host?

> 2) In the guest, track the size of hints in progress, cap at the
> hinting_size.
> 
> 3) Document hinting behavior
> 
> "When hinting is enabled, memory up to hinting_size might temporarily be
> removed from your guest in order to be hinted to the hypervisor. This is
> only for a very short time, but might affect applications. Consider the
> hinting_size when sizing your guest. If your application was tested with
> XGB and a hinting size of 1G is used, please configure X+1GB for the
> guest. Otherwise, performance degradation might be possible."

OK, so let's start with this. Now let us assume that guest follows
the advice.  We thus know that 1GB is not needed for guest applications.
So why do we want to allow applications to still use this extra memory?

> 4) Do the loop/yield on OOM as discussed to improve performance when OOM
> and avoid false OOM triggers just to be sure.

Yes, I'm not against trying the simpler approach as a first step.  But
then we need this path actually tested so see whether hinting introduced
unreasonable overhead on this path.  And it is tricky to test oom as you
are skating close to system's limits. That's one reason I prefer
avoiding oom handler if possible.

When you say yield, I would guess that would involve config space access
to the balloon to flush out outstanding hints?

> 
> BTW, one alternatives I initially had in mind was to add pages from the
> buffer from the OOM handler only and putting these pages back into the
> buffer once freed.

I don't think that works easily - pages get used so we can't
return them into the buffer. Another problem with only handling oom
is that oom is a guest decision. So host really can't
enforce any limits even if it wants to.

> I thought this might help for certain memory offline
> scenarios where pages stuck in the buffer might hinder offlining of
> memory. And of course, improve performance as the buffer is only touched
> when really needed. But it would only help for memory (e.g. DIMM) added
> after boot, so it is also not 100% safe. Also, same issues as with your
> given approach.

So you can look at this approach as a combination of
- balloon inflate with separate accounting
- deflate on oom
- hinting
?

Put this way, it seems rather uncontroversial, right?




> -- 
> 
> Thanks,
> 
> David / dhildenb


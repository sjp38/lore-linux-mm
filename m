Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B8056C43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 00:47:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 62E9D214AE
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 00:47:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="15ssqlbM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 62E9D214AE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E75BF8E0003; Tue, 12 Mar 2019 20:47:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E221F8E0002; Tue, 12 Mar 2019 20:47:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CE9B08E0003; Tue, 12 Mar 2019 20:47:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 96C6E8E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 20:47:05 -0400 (EDT)
Received: by mail-oi1-f200.google.com with SMTP id p65so9163oib.15
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 17:47:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=mLj4qcCQx2Pn+uXcFJ85DvqflvBkrhEGWb75t5OlUng=;
        b=hdiWpYv48bI73z2Hub3prXsVmjRIcquCL6zz7zq4jMm90I1AP8RE0gIeTuFn54I4Ci
         vRE/5PMPCr1MGUwCcPlSIIYwoIK63G3xHO/ceBN0hsX7seOcmgsEebjDgSvrv0esiwEZ
         5R9nxyz3m85XKZAuStfM9rr24YVflCPVxzTCHPTk1xWImbCOz6Ek9tJw64uTUpH4RCOa
         hcsIODsH5axtoyiPr5E3rcS7xQz5U6XGR8PW6UkScyKU5jbDJiwwYKnAImT8zf/iAuwJ
         cfo1KklS1VRMrlwsRoO4pczkPn8VCyUhtKsuEEvHXjIXoNDYEFqQkJeuZzKjdczERsL0
         9IIQ==
X-Gm-Message-State: APjAAAW+uJDRv1st+SH41NhmHof7AzxGCDUbm2QaZ/PVnkqDN73v5DLs
	Utx+PTqJZMTBQMOU3b9eZRgxXK//8Xf40otZIxll9DPMzVWJkyNcbsA+n1cKm5LswKOxV4fwDPR
	4NVRuKksNHjgiilMu9PQjwVnWf3JXIVcTSobJMiUQw4xO7EI3ocToqF9XFNQmTxYC+Q==
X-Received: by 2002:aca:42d7:: with SMTP id p206mr124715oia.82.1552438024996;
        Tue, 12 Mar 2019 17:47:04 -0700 (PDT)
X-Received: by 2002:aca:42d7:: with SMTP id p206mr124688oia.82.1552438023972;
        Tue, 12 Mar 2019 17:47:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552438023; cv=none;
        d=google.com; s=arc-20160816;
        b=pFOb55GTuuqbKv3nr4oNCeMDsK6QZRAE/DI9LCVEpRDUBwoSwOeO5lIme+LoKLZyAG
         hOa4yu3JcjPPjHcuizSIhO9gJyzIx0KpMBTt8BJHmiMS2Nwjc8eEij086RkOOIgJarVf
         zpQ90DLx7OrQw8lh1vqPwveZbZDiXmqXO6XHXiruOowyLerSdvxBvM8+ZhlBhCexIot0
         kbHJFJuhG9b3Qn3mHFWy08YmxXHu2bs2+U2Hdvxot7fahvpk0Xj+RtT9xoTOMhgiW6ro
         9Wz8A7sS2YdPX4Xe4ImxopTYqTNJiSw7D6xt+1+r569pee70g0q5FSF8Fs0GUEvK8pad
         Ohrw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=mLj4qcCQx2Pn+uXcFJ85DvqflvBkrhEGWb75t5OlUng=;
        b=HM5QZojmUqAgyRqLS9fUZyCs9LWXywpZ9brmegQlR5X9pUlt6XDe+SstGakn8yQR4E
         Byk4TZz4XeZcwtllfOa0BYSsoBvf1airlnBc8jwgxfGtgm/UBZkp3HYmj+BNsO0lADFm
         BBeHwb6TbAL2lVxX95Eggx0Q8zIFfYjATbBTFxrPlb+ZqkYRzJqIK5P7gyP0vln4gkP8
         gb1PBZ6H5ccfaQFeiJugrcxWddrcwJnOtf/jyGrfa5V4BdpoiDqaLez6Kb7azmIewseK
         SOWPoLDqtCknwxG0ZutIUYpSdSwlUSJ6AsvOrYM/TdMBKv6Y1Z95Ac0+VSV1cDuRsI5L
         iJdQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=15ssqlbM;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l6sor1762916otq.42.2019.03.12.17.47.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Mar 2019 17:47:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=15ssqlbM;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=mLj4qcCQx2Pn+uXcFJ85DvqflvBkrhEGWb75t5OlUng=;
        b=15ssqlbMFEuple84d+nWcgJNQ+bAE69hLg9vgjJlg8ROS8W3lxVvATNXiK5GYlrhH5
         vM7DtUN6LU4Nph550Md5x6+LDDByKkR7x0CEvquaxELcbFthbflmxYnASUgkD0EcakZe
         6EfSI0yb+3TdgO3bdr1FKqY8Bv9kp6XCmarSWTU7v334wVAU2RIov9oG+wuBqtG/AjQc
         MYVlQ90xUZw2zcLNTx2lciilggH14qDDAJRCKbtzx81ayHUI/yb4vlytEJkPVEnXT7R/
         r3hhcDUTZgb/5c4rc2pQF7eiUv+g7JgXXvk8qoLAKpTXRyphRw+B1TRkAJSsoGQy/GMA
         1nFQ==
X-Google-Smtp-Source: APXvYqw0Mpk2Nx7zxk3e2cteUAAoUeiLm5q90A8CIm9oOmu4nbmapF5pCiWJ9T7GcsgSrbuN3twHgSfOBxhzOCdFnjc=
X-Received: by 2002:a9d:760a:: with SMTP id k10mr1705011otl.367.1552438022857;
 Tue, 12 Mar 2019 17:47:02 -0700 (PDT)
MIME-Version: 1.0
References: <20190305141635.8134e310ba7187bc39532cd3@linux-foundation.org>
 <CAA9_cmd2Z62Z5CSXvne4rj3aPSpNhS0Gxt+kZytz0bVEuzvc=A@mail.gmail.com>
 <20190307094654.35391e0066396b204d133927@linux-foundation.org>
 <20190307185623.GD3835@redhat.com> <CAPcyv4gkxmmkB0nofVOvkmV7HcuBDb+1VLR9CSsp+m-QLX_mxA@mail.gmail.com>
 <20190312152551.GA3233@redhat.com> <CAPcyv4iYzTVpP+4iezH1BekawwPwJYiMvk2GZDzfzFLUnO+RgA@mail.gmail.com>
 <20190312190606.GA15675@redhat.com> <CAPcyv4g-z8nkM1B65oR-3PT_RFQbmQMsM-J-P0-nzyvvJ8gVog@mail.gmail.com>
 <20190312145214.9c8f0381cf2ff2fc2904e2d8@linux-foundation.org> <20190313001018.GA3312@redhat.com>
In-Reply-To: <20190313001018.GA3312@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 12 Mar 2019 17:46:51 -0700
Message-ID: <CAPcyv4huAHnWoLQHhVRC_U6c-1DG2joOktA-ZWa-TQ1=KaTQLA@mail.gmail.com>
Subject: Re: [PATCH 09/10] mm/hmm: allow to mirror vma of a file on a DAX
 backed filesystem
To: Jerome Glisse <jglisse@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Ralph Campbell <rcampbell@nvidia.com>, 
	John Hubbard <jhubbard@nvidia.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 12, 2019 at 5:10 PM Jerome Glisse <jglisse@redhat.com> wrote:
>
> On Tue, Mar 12, 2019 at 02:52:14PM -0700, Andrew Morton wrote:
> > On Tue, 12 Mar 2019 12:30:52 -0700 Dan Williams <dan.j.williams@intel.com> wrote:
> >
> > > On Tue, Mar 12, 2019 at 12:06 PM Jerome Glisse <jglisse@redhat.com> wrote:
> > > > On Tue, Mar 12, 2019 at 09:06:12AM -0700, Dan Williams wrote:
> > > > > On Tue, Mar 12, 2019 at 8:26 AM Jerome Glisse <jglisse@redhat.com> wrote:
> > > [..]
> > > > > > Spirit of the rule is better than blind application of rule.
> > > > >
> > > > > Again, I fail to see why HMM is suddenly unable to make forward
> > > > > progress when the infrastructure that came before it was merged with
> > > > > consumers in the same development cycle.
> > > > >
> > > > > A gate to upstream merge is about the only lever a reviewer has to
> > > > > push for change, and these requests to uncouple the consumer only
> > > > > serve to weaken that review tool in my mind.
> > > >
> > > > Well let just agree to disagree and leave it at that and stop
> > > > wasting each other time
> > >
> > > I'm fine to continue this discussion if you are. Please be specific
> > > about where we disagree and what aspect of the proposed rules about
> > > merge staging are either acceptable, painful-but-doable, or
> > > show-stoppers. Do you agree that HMM is doing something novel with
> > > merge staging, am I off base there?
> >
> > You're correct.  We chose to go this way because the HMM code is so
> > large and all-over-the-place that developing it in a standalone tree
> > seemed impractical - better to feed it into mainline piecewise.
> >
> > This decision very much assumed that HMM users would definitely be
> > merged, and that it would happen soon.  I was skeptical for a long time
> > and was eventually persuaded by quite a few conversations with various
> > architecture and driver maintainers indicating that these HMM users
> > would be forthcoming.
> >
> > In retrospect, the arrival of HMM clients took quite a lot longer than
> > was anticipated and I'm not sure that all of the anticipated usage
> > sites will actually be using it.  I wish I'd kept records of
> > who-said-what, but I didn't and the info is now all rather dissipated.
> >
> > So the plan didn't really work out as hoped.  Lesson learned, I would
> > now very much prefer that new HMM feature work's changelogs include
> > links to the driver patchsets which will be using those features and
> > acks and review input from the developers of those driver patchsets.
>
> This is what i am doing now and this patchset falls into that. I did
> post the ODP and nouveau bits to use the 2 new functions (dma map and
> unmap). I expect to merge both ODP and nouveau bits for that during
> the next merge window.
>
> Also with 5.1 everything that is upstream is use by nouveau at least.
> They are posted patches to use HMM for AMD, Intel, Radeon, ODP, PPC.
> Some are going through several revisions so i do not know exactly when
> each will make it upstream but i keep working on all this.
>
> So the guideline we agree on:
>     - no new infrastructure without user
>     - device driver maintainer for which new infrastructure is done
>       must either sign off or review of explicitly say that they want
>       the feature I do not expect all driver maintainer will have
>       the bandwidth to do proper review of the mm part of the infra-
>       structure and it would not be fair to ask that from them. They
>       can still provide feedback on the API expose to the device
>       driver.
>     - driver bits must be posted at the same time as the new infra-
>       structure even if they target the next release cycle to avoid
>       inter-tree dependency
>     - driver bits must be merge as soon as possible

What about EXPORT_SYMBOL_GPL?

>
> Thing we do not agree on:
>     - If driver bits miss for any reason the +1 target directly
>       revert the new infra-structure. I think it should not be black
>       and white and the reasons why the driver bit missed the merge
>       window should be taken into account. If the feature is still
>       wanted and the driver bits missed the window for simple reasons
>       then it means that we push everything by 2 release ie the
>       revert is done in +1 then we reupload the infra-structure in
>       +2 and finaly repush the driver bit in +3 so we loose 1 cycle.

I think that pain is reasonable.

>       Hence why i would rather that the revert would only happen if
>       it is clear that the infrastructure is not ready or can not
>       be use in timely (over couple kernel release) fashion by any
>       drivers.

This seems too generous to me, but in the interest of moving this
discussion forward let's cross that bridge if/when it happens.
Hopefully the threat of this debate recurring means consumers put in
the due diligence to get things merged at infrastructure + 1 time.


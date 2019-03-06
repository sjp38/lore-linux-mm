Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 718F2C43381
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 19:24:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2130A20661
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 19:24:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="JlpLV90R"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2130A20661
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B4B408E0003; Wed,  6 Mar 2019 14:24:38 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AFA978E0002; Wed,  6 Mar 2019 14:24:38 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9E9CC8E0003; Wed,  6 Mar 2019 14:24:38 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 739D58E0002
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 14:24:38 -0500 (EST)
Received: by mail-io1-f72.google.com with SMTP id k24so10452379ioh.11
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 11:24:38 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=ZiEiSPvTWNYJkEcELHi6QZ0IqecrFI4s8OYugZS1pk8=;
        b=a6ZFZVUT7ZqC5dGCTpwBwzNjoRcH8UxiHyY/9ziESYkWvjErzSk9oCXefBsu/7yBgW
         XXE6EY/g0NFvwIxRQ6twf+nCdKJ/wj6T2m6dkvFNXqjIRcV6EevxVMgBkrWA6A+r1CGf
         HFTujUuiTve3nRdQw5BLbQOmIQrq1X5ZCNuhgcFMAwWoipqcV8P8F1o9T0C5zvp1h4B0
         +xyKlJrHTehCWOyerL8vGMPO5PYtUsNGv3FUucPbd3qFpyCdl1u4mLk4mCvVRdIl6xUz
         E73EvObt/BF/TRIsviLmiyTj7BQKBzaxCNs8eYv0feuITgP5yv//d2wSB1h7OiiT/gTM
         TkRg==
X-Gm-Message-State: APjAAAWPaWmRgoFwmaprR22f1GrIuEEThpC+Fa2eeVDxpxFjywBw/P6G
	AB9ZWUE33SplgCUPPrJ4EaQoQkNy4HemrHNEkwVtP0ScfH+AK3V7D5xI1Sw6P4xn199WZU6FLcM
	9S0k7jl+RtsMfyMHHrgFcd+Z9DXR8lDi7jgazXqAOsJByBadheXR+UQrjXYhOnVjMv617I3mkek
	/lPOp/J5UdTxyxPXNf2u5V5ICSETgi+v6pIwGntA3ul36rTXh986dpzbp0YYkuwTZ1G0s74rtjp
	hVvZAgc6dxMzYdn3vpWvFCMqGb0OPavdS9eSNOo/npb0saSE2ymWBhaEQEVK4PnwDnicDJ0qiZF
	wFloscuydBOuJ3HMkY6stCw13oq2DiOPOczEKEBhktKvOJvwUfz6iqatx5U1//F7Sgrltnfv4wg
	T
X-Received: by 2002:a24:2c11:: with SMTP id i17mr2918768iti.146.1551900278188;
        Wed, 06 Mar 2019 11:24:38 -0800 (PST)
X-Received: by 2002:a24:2c11:: with SMTP id i17mr2918741iti.146.1551900277289;
        Wed, 06 Mar 2019 11:24:37 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551900277; cv=none;
        d=google.com; s=arc-20160816;
        b=DR0lNLLbN38+3mJ4lRA5h5bhfCEKaoofVkZ362DaQgwM61DqG3gwryyaaEZTNzp5cY
         zkEvWrZOpuRF2/hQJC3Qs26j3TcPrP8UUyfhc8jjCVPLhMkFx6gQwSA3LXRCuRZjxoar
         aCApSboDZrUuWsJDgRBNg8cPrAxs50wsorRkrq+5/JcLINAymU79gcN78irDzmdp+br0
         db4m/DlSeKCE9tvolSArCJ8AmC82k4jQC7JR7U34IL0L219Lv4WKfT/Jk4+U2RQs08/o
         P6d8sFs9Enr0G6lsNG9ebClzbLD+ancwh116bk8J3iTbqRYOqol2wjMb1741rtAeIVu2
         74FA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=ZiEiSPvTWNYJkEcELHi6QZ0IqecrFI4s8OYugZS1pk8=;
        b=ojTVIQR5bYhcF19nTB/g70fY8pyEjZnGAbzKqgs43a89PpbZPsvSG2e973555MtCTA
         +5nNxbPhnb0UgMhGpym5i5hRSwaTRniJccnkaK6Y1iXLzZADJyxZBK0NYw9Vx8npQrjw
         LHaAyg9W/E1L+TuxqPqc+gqHFb3Q/Hxs2TN8aShynd8ACucabgalktPDrNLbozJhq1Ba
         tfEKFneAZx1lb6cLIHq5/XBzVUxg+BB8NdhQ2XU0WPW1vDZfdPJpD2OSfdYAnMg2tp1p
         33n47QW5ETI34nreI2sLjZ/QiWK1sTmIWmM1SlYIXfEIqbX1Fg+VBKW8dOLvfzntMMSa
         /FEQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=JlpLV90R;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m13sor1367075iop.30.2019.03.06.11.24.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 06 Mar 2019 11:24:37 -0800 (PST)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=JlpLV90R;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=ZiEiSPvTWNYJkEcELHi6QZ0IqecrFI4s8OYugZS1pk8=;
        b=JlpLV90RSAH9k2d8QE8l2UpOhkwPDT2DBu7qsYNQWSwJ3b8kyHxkbeLUmnOZam92wO
         ptfQvJSaMm4OWI6oL/DKWwLBGZogWE1idXjwrp/N5KZ2NfX+MMWjqhHs3BGW5DuYQ0/X
         V107f0kLkqdaUYWTcHuEof422ZXnOJ1fDogcM4pWurNbKtJFEN8tQefl0+BnW5g97Ned
         L3K62T0wOUYE/xQS2E21HWxLRsvfUNUKvpxoDhzXmWIG8nf0JN+RSnu0rYu+YN7w1g40
         caBTO1XHQLns3wytFIijKK/mIKYrycSIBDoenfHez74MJcrPDEQW6PPhZ94a6XFXIxti
         pqCg==
X-Google-Smtp-Source: APXvYqxSUzuRjOdKAez74kTF5p1HGD/t+z3j7naZJe5Kawrl9zyHEpoKMYeP3t+JkBAQkFnxYzs4nIKVc/P54WqFdUA=
X-Received: by 2002:a5e:8c14:: with SMTP id n20mr3926504ioj.200.1551900276823;
 Wed, 06 Mar 2019 11:24:36 -0800 (PST)
MIME-Version: 1.0
References: <20190306155048.12868-1-nitesh@redhat.com> <20190306110501-mutt-send-email-mst@kernel.org>
 <bd029eb2-501a-8d2d-5f75-5d2b229c7e75@redhat.com> <20190306130955-mutt-send-email-mst@kernel.org>
 <afc52d00-c769-01a0-949a-8bc96af47fab@redhat.com> <20190306133826-mutt-send-email-mst@kernel.org>
 <3f87916d-8d18-013c-8988-9eb516c9cd2e@redhat.com> <CAKgT0UdqCb37VNe7pABBYBXYFrVzYdPntmPf-V6ZYp9DdwmxYA@mail.gmail.com>
 <7b98b7b3-68f5-e4e0-1454-2217f41e46ad@redhat.com>
In-Reply-To: <7b98b7b3-68f5-e4e0-1454-2217f41e46ad@redhat.com>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Wed, 6 Mar 2019 11:24:26 -0800
Message-ID: <CAKgT0UePn86cnjzietzuqdosjJH3McH2xDQ3ocjbujMKdsk7Pw@mail.gmail.com>
Subject: Re: [RFC][Patch v9 0/6] KVM: Guest Free Page Hinting
To: David Hildenbrand <david@redhat.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, Nitesh Narayan Lal <nitesh@redhat.com>, kvm list <kvm@vger.kernel.org>, 
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, 
	Paolo Bonzini <pbonzini@redhat.com>, lcapitulino@redhat.com, pagupta@redhat.com, 
	wei.w.wang@intel.com, Yang Zhang <yang.zhang.wz@gmail.com>, 
	Rik van Riel <riel@surriel.com>, dodgen@google.com, 
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, dhildenb@redhat.com, 
	Andrea Arcangeli <aarcange@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 6, 2019 at 11:18 AM David Hildenbrand <david@redhat.com> wrote:
>
> On 06.03.19 20:08, Alexander Duyck wrote:
> > On Wed, Mar 6, 2019 at 11:00 AM David Hildenbrand <david@redhat.com> wrote:
> >>
> >> On 06.03.19 19:43, Michael S. Tsirkin wrote:
> >>> On Wed, Mar 06, 2019 at 01:30:14PM -0500, Nitesh Narayan Lal wrote:
> >>>>>> Here are the results:
> >>>>>>
> >>>>>> Procedure: 3 Guests of size 5GB is launched on a single NUMA node with
> >>>>>> total memory of 15GB and no swap. In each of the guest, memhog is run
> >>>>>> with 5GB. Post-execution of memhog, Host memory usage is monitored by
> >>>>>> using Free command.
> >>>>>>
> >>>>>> Without Hinting:
> >>>>>>                  Time of execution    Host used memory
> >>>>>> Guest 1:        45 seconds            5.4 GB
> >>>>>> Guest 2:        45 seconds            10 GB
> >>>>>> Guest 3:        1  minute               15 GB
> >>>>>>
> >>>>>> With Hinting:
> >>>>>>                 Time of execution     Host used memory
> >>>>>> Guest 1:        49 seconds            2.4 GB
> >>>>>> Guest 2:        40 seconds            4.3 GB
> >>>>>> Guest 3:        50 seconds            6.3 GB
> >>>>> OK so no improvement.
> >>>> If we are looking in terms of memory we are getting back from the guest,
> >>>> then there is an improvement. However, if we are looking at the
> >>>> improvement in terms of time of execution of memhog then yes there is none.
> >>>
> >>> Yes but the way I see it you can't overcommit this unused memory
> >>> since guests can start using it at any time.  You timed it carefully
> >>> such that this does not happen, but what will cause this timing on real
> >>> guests?
> >>
> >> Whenever you overcommit you will need backup swap. There is no way
> >> around it. It just makes the probability of you having to go to disk
> >> less likely.
> >>
> >> If you assume that all of your guests will be using all of their memory
> >> all the time, you don't have to think about overcommiting memory in the
> >> first place. But this is not what we usually have.
> >
> > Right, but the general idea is that free page hinting allows us to
> > avoid having to use the swap if we are hinting the pages as unused.
> > The general assumption we are working with is that some percentage of
> > the VMs are unused most of the time so you can share those resources
> > between multiple VMs and have them free those up normally.
>
> Yes, similar to VCPU yielding or playin scheduling when the VCPU is
> spleeping. Instead of busy looping, hand over the resource to somebody
> who can actually make use of it.
>
> >
> > If we can reduce swap usage we can improve overall performance and
> > that was what I was pointing out with my test. I had also done
> > something similar to what Nitesh was doing with his original test
> > where I had launched 8 VMs with 8GB of memory per VM on a system with
> > 32G of RAM and only 4G of swap. In that setup I could keep a couple
> > VMs busy at a time without issues, and obviously without the patch I
> > just started to OOM qemu instances and  could only have 4 VMs at a
> > time running at maximum.
>
> While these are nice experiments (especially to showcase reduced swap
> usage!), I would not suggest to use 4GB of swap on a x2 overcomited
> system (32GB overcommited). Disks are so cheap nowadays that one does
> not have to play with fire.

Right. The only reason for using 4G is because the system normally has
128G of RAM available and I didn't really think I would need swap for
the system when I originally configured it.

> But yes, reducing swap usage implies overall system performance (unless
> the hinting is terribly slow :) ). Reducing swap usage, not swap space :)

Right. Also the swap is really a necessity if we are going to look at
things like MADV_FREE as I have not seen us really start to free up
resources until we are starting to put some pressure on swap.


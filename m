Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 419A5C32750
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 21:09:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 05D812067D
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 21:09:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 05D812067D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 829F08E0003; Tue, 30 Jul 2019 17:09:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 801DD8E0001; Tue, 30 Jul 2019 17:09:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 717338E0003; Tue, 30 Jul 2019 17:09:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 51D7B8E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 17:09:56 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id h198so56157281qke.1
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 14:09:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=6d3g5Eb7RssGimuUVLnc9Oe3VuINI0PuovERS1dVP0w=;
        b=MNB7yLSAyAGSbbUTQEnS/KRqaKyVRShb3SXLyvb925z+LsMLYnwu+FKWu+JT5H3K4S
         hG/0VROE0nzLbpmRakd0ZfBSXDdUMcpmrbRUtJZrneX3kBDbwHNQv4wErD/q8AJitKmt
         CTzZWSgZ+gTB+qhOQwCL+Ae3E84+UYc8K7hTqv8Gnzh6HJFkR4J2GyV+jadhTcR7mNUr
         qPoAQgpLD0rjwx0vsE9ZgMmxi48wctV7U15Ue7v7f6PCAJ2K085t0+QGuyEx912qHrBu
         Bmscxl5obY5bnRsMfiGQcUSywCesBw94Wj7JO1izVxEKO2VmhwAyDSQt4KidD9FdENLR
         h0vQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAX3JZg9GBAulatsXc1RpvgT4BWvLpzwXp6Pxugmodwareyk8XF3
	6Vuy4sYPqUgL4DSOqEbTh4FPTHExsUkg+499Uj0r9NrbDQ2xymkk+JTxi2y/PbMpDQrgj6GIDCe
	TLKYddc+2081C7XlPW2JPnHZHdIxkT29McsrAt2WYHjLXmDMmqiKnNKsOtoykzYQ=
X-Received: by 2002:a0c:d981:: with SMTP id y1mr86240516qvj.104.1564520996121;
        Tue, 30 Jul 2019 14:09:56 -0700 (PDT)
X-Received: by 2002:a0c:d981:: with SMTP id y1mr86240487qvj.104.1564520995605;
        Tue, 30 Jul 2019 14:09:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564520995; cv=none;
        d=google.com; s=arc-20160816;
        b=ndBipK51j+D7o06ZS4EgFPpmtRe5QI1tU70OfzbLbPQtexdxZgSha2ywm4izl/FTOq
         qeAVgdeUu68eai4VyjNXup8dndjZpLyJksc4EXjSzq1up+uQDTLu/gPFYm8975WJlCD9
         uVIbsSTtIGNhn/VtltcStifJ8hXgHAkj9ANkmPf5oMsV2XMgTGMsS0fUgHOdLFnFsLhT
         aZKBv2UOeskwNoCZZ2744mXp9N5nP1FSHzJRTMGLOWsOYTD8OmLQfl/LecDxioileQrH
         03v8ehq0jjlqULAHwy/F257+0OtwYyI0TqZwzBU/B/KhYOAkamYp52tNjWb5lwd7rZcA
         JFXg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=6d3g5Eb7RssGimuUVLnc9Oe3VuINI0PuovERS1dVP0w=;
        b=NuJYOVoy8uf8sxdhKCaQx7slABWshHJlWtBX6Z6vrc3bmZgsN5E+Wd4YLlUrfKQW4P
         toYeH4o5M0wwgFFTKO5dbo8ukH8I03+4PgRrnp0K+st/lgGIgikyGRJVgtAxNczF82Lm
         weQ+fSRgER2WPwL7EdvdVPAbp3cDCBg4V1QO+0SKOVhIgxYjmoLNm3CzHzQZvgAerV3j
         1x4staS4KeMDFKcXW2h6ZNhN6jiM1ktiYql+hTIfTdB/yl5ePIFQIAf/bN6T/QaJrxW2
         RfYgCaRpInOZcoP1qUPFze9N48wPdm3vOBrUeLcdCY3Fs+Cgf6doYYB+oAX97Gjcgjom
         jHEA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t5sor36748160qke.148.2019.07.30.14.09.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 30 Jul 2019 14:09:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: APXvYqxMSvB5TKi/+chiBT7wCFVw5w/PWL6aSh+LFGiBGlU52oTw/IDUNyDM/wE/qDgVVzAvy7l85w==
X-Received: by 2002:a37:9b92:: with SMTP id d140mr76382522qke.443.1564520995282;
        Tue, 30 Jul 2019 14:09:55 -0700 (PDT)
Received: from dennisz-mbp.dhcp.thefacebook.com ([2620:10d:c091:500::2:6988])
        by smtp.gmail.com with ESMTPSA id k33sm33021721qte.69.2019.07.30.14.09.54
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jul 2019 14:09:54 -0700 (PDT)
Date: Tue, 30 Jul 2019 17:09:52 -0400
From: Dennis Zhou <dennis@kernel.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Uladzislau Rezki <urezki@gmail.com>,
	sathyanarayanan.kuppuswamy@linux.intel.com,
	akpm@linux-foundation.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH v1 1/1] mm/vmalloc.c: Fix percpu free VM area search
 criteria
Message-ID: <20190730210952.GA62702@dennisz-mbp.dhcp.thefacebook.com>
References: <20190729232139.91131-1-sathyanarayanan.kuppuswamy@linux.intel.com>
 <20190730204643.tsxgc3n4adb63rlc@pc636>
 <d121eb22-01fd-c549-a6e8-9459c54d7ead@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d121eb22-01fd-c549-a6e8-9459c54d7ead@intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 30, 2019 at 01:54:06PM -0700, Dave Hansen wrote:
> On 7/30/19 1:46 PM, Uladzislau Rezki wrote:
> >> +		/*
> >> +		 * If required width exeeds current VA block, move
> >> +		 * base downwards and then recheck.
> >> +		 */
> >> +		if (base + end > va->va_end) {
> >> +			base = pvm_determine_end_from_reverse(&va, align) - end;
> >> +			term_area = area;
> >> +			continue;
> >> +		}
> >> +
> >>  		/*
> >>  		 * If this VA does not fit, move base downwards and recheck.
> >>  		 */
> >> -		if (base + start < va->va_start || base + end > va->va_end) {
> >> +		if (base + start < va->va_start) {
> >>  			va = node_to_va(rb_prev(&va->rb_node));
> >>  			base = pvm_determine_end_from_reverse(&va, align) - end;
> >>  			term_area = area;
> >> -- 
> >> 2.21.0
> >>
> > I guess it is NUMA related issue, i mean when we have several
> > areas/sizes/offsets. Is that correct?
> 
> I don't think NUMA has anything to do with it.  The vmalloc() area
> itself doesn't have any NUMA properties I can think of.  We don't, for
> instance, partition it into per-node areas that I know of.
> 
> I did encounter this issue on a system with ~100 logical CPUs, which is
> a moderate amount these days.
> 

Percpu memory does have this restriction when we embed the first chunk
as we need to preserve the offsets. So that is when we'd require
multiple areas in the vma.

I didn't see the original patches come through, but this seems like it
restores the original functionality. FWIW, this way of finding space
isn't really smart, so it's possible we want to revisit this.

Acked-by: Dennis Zhou <dennis@kernel.org>

Thanks,
Dennis


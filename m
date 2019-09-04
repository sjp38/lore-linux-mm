Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2E133C3A5A9
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 10:37:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F074A22CF5
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 10:37:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F074A22CF5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8DD5F6B0007; Wed,  4 Sep 2019 06:37:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 88E536B0008; Wed,  4 Sep 2019 06:37:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7A58A6B000A; Wed,  4 Sep 2019 06:37:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0110.hostedemail.com [216.40.44.110])
	by kanga.kvack.org (Postfix) with ESMTP id 5B4476B0007
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 06:37:23 -0400 (EDT)
Received: from smtpin19.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id EE98B83F4
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 10:37:22 +0000 (UTC)
X-FDA: 75896886324.19.chalk89_40674bd2d9e02
X-HE-Tag: chalk89_40674bd2d9e02
X-Filterd-Recvd-Size: 5380
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf34.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 10:37:22 +0000 (UTC)
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 5C30E7BDA7
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 10:37:21 +0000 (UTC)
Received: by mail-qk1-f198.google.com with SMTP id 72so13491324qki.12
        for <linux-mm@kvack.org>; Wed, 04 Sep 2019 03:37:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:content-transfer-encoding
         :in-reply-to;
        bh=3U+t4+2zJKbuXz99iZtKQog9/vhKyWkpmsxRg7JGQDE=;
        b=eLDUdncxFHoHAP/zeBsq/pD/MVDSput7RaSSZHxsJjLpOnBUCUVQGRrh5mo3Wr0+x9
         lroq3i4F1mjFboZECyABij+MYPayi7k8m7/Udg2aU+khH9fN0jNTZtIkk8BB6ktHvXwz
         OWMNqfKEhxFMEePAzi84L9WYmP38zMyFYs2dbPHedzKGJ2pgLkXElGzQo/xrXZd9Nql6
         zShEAthYAp/nc1Uh4LQ/f1MCHdP3s/2VV3xtkxa3VAJupIcssuxAP/sASLzZmO+NSP+Q
         HHRnVMurmqUM024+Uq9hMUu3O1XaJrBXNnBEtZRUMEibTFut+Fiou2E3Pn7w5LM0euqw
         1cxA==
X-Gm-Message-State: APjAAAVotgNOg2dSr541RSu/9/sXwE/GsC7xPIdxu1YGVd9gG3+QVW+X
	wYBgRI0SjW0nvVzlNk9zG3BWZRf/+Ga7FqJqdx/8Cgwqkza4OAE7RWzpiSwT8bSZvQwcOSt2NiC
	jBdgQPIKrXVs=
X-Received: by 2002:a37:4a88:: with SMTP id x130mr39287228qka.501.1567593440685;
        Wed, 04 Sep 2019 03:37:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwzddU8SouAdok0NmEiOpSZh4ZsJm0UIpWp7Qa5JYWIOzRtEyne94p1wCOaQIiKI9ZMVFqLQg==
X-Received: by 2002:a37:4a88:: with SMTP id x130mr39287214qka.501.1567593440533;
        Wed, 04 Sep 2019 03:37:20 -0700 (PDT)
Received: from redhat.com (bzq-79-176-40-226.red.bezeqint.net. [79.176.40.226])
        by smtp.gmail.com with ESMTPSA id e7sm4085888qto.43.2019.09.04.03.37.17
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 04 Sep 2019 03:37:19 -0700 (PDT)
Date: Wed, 4 Sep 2019 06:37:15 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Nadav Amit <namit@vmware.com>
Cc: Jason Wang <jasowang@redhat.com>,
	"virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	David Hildenbrand <david@redhat.com>
Subject: Re: [PATCH] mm/balloon_compaction: suppress allocation warnings
Message-ID: <20190904063703-mutt-send-email-mst@kernel.org>
References: <20190820091646.29642-1-namit@vmware.com>
 <ba01ec8c-19c3-847c-a315-2f70f4b1fe31@redhat.com>
 <5BBC6CB3-2DCD-4A95-90C9-7C23482F9B32@vmware.com>
 <85c72875-278f-fbab-69c9-92dc1873d407@redhat.com>
 <FC42B62F-167F-4D7D-ADC5-926B36347E82@vmware.com>
 <2aa52636-4ca7-0d47-c5bf-42408af3ea0f@redhat.com>
 <D4105FF4-5DF3-4DB5-9325-855B63CD9AAD@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <D4105FF4-5DF3-4DB5-9325-855B63CD9AAD@vmware.com>
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 21, 2019 at 07:44:33PM +0000, Nadav Amit wrote:
> > On Aug 21, 2019, at 12:13 PM, David Hildenbrand <david@redhat.com> wr=
ote:
> >=20
> > On 21.08.19 18:34, Nadav Amit wrote:
> >>> On Aug 21, 2019, at 9:29 AM, David Hildenbrand <david@redhat.com> w=
rote:
> >>>=20
> >>> On 21.08.19 18:23, Nadav Amit wrote:
> >>>>> On Aug 21, 2019, at 9:05 AM, David Hildenbrand <david@redhat.com>=
 wrote:
> >>>>>=20
> >>>>> On 20.08.19 11:16, Nadav Amit wrote:
> >>>>>> There is no reason to print warnings when balloon page allocatio=
n fails,
> >>>>>> as they are expected and can be handled gracefully.  Since VMwar=
e
> >>>>>> balloon now uses balloon-compaction infrastructure, and suppress=
ed these
> >>>>>> warnings before, it is also beneficial to suppress these warning=
s to
> >>>>>> keep the same behavior that the balloon had before.
> >>>>>=20
> >>>>> I am not sure if that's a good idea. The allocation warnings are =
usually
> >>>>> the only trace of "the user/admin did something bad because he/sh=
e tried
> >>>>> to inflate the balloon to an unsafe value". Believe me, I process=
ed a
> >>>>> couple of such bugreports related to virtio-balloon and the warni=
ng were
> >>>>> very helpful for that.
> >>>>=20
> >>>> Ok, so a message is needed, but does it have to be a generic frigh=
tening
> >>>> warning?
> >>>>=20
> >>>> How about using __GFP_NOWARN, and if allocation do something like:
> >>>>=20
> >>>> pr_warn(=E2=80=9CBalloon memory allocation failed=E2=80=9D);
> >>>>=20
> >>>> Or even something more informative? This would surely be less inti=
midating
> >>>> for common users.
> >>>=20
> >>> ratelimit would make sense :)
> >>>=20
> >>> And yes, this would certainly be nicer.
> >>=20
> >> Thanks. I will post v2 of the patch.
> >=20
> > As discussed in v2, we already print a warning in virtio-balloon, so =
I
> > am fine with this patch.
> >=20
> > Reviewed-by: David Hildenbrand <david@redhat.com>
>=20
> Michael,
>=20
> If it is possible to get it to 5.3, to avoid behavioral change for VMwa=
re
> balloon users, it would be great.
>=20
> Thanks,
> Nadav

Just back from vacation, I'll try.



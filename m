Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7E179C282CE
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 09:01:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3B9B1222CA
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 09:01:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="VIMY0KrK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3B9B1222CA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C53658E0002; Wed, 13 Feb 2019 04:01:39 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C012B8E0001; Wed, 13 Feb 2019 04:01:39 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AC8358E0002; Wed, 13 Feb 2019 04:01:39 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7D4E98E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 04:01:39 -0500 (EST)
Received: by mail-yw1-f69.google.com with SMTP id r67so123732ywd.4
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 01:01:39 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=nOxAq2jgYrMbNTBlWFr73Rc+ViApmre//M8IaWoP5S0=;
        b=DoRyCcs5MYL1K0Ac8foZuk1so+ETvXzjWxhvjjV5eBidoZcrkdykvFHVMDV7RM237h
         o8eNNE+UmE2fjAdrq7ZegPZn3bmeVD0la9vOAGTZolsd6tE1s2apgZmfqajFMjKEAvFz
         XcmlmRQE8LlcBLII5YdqbdSTO9RoGVhewgUj6058fLASPZDopVkFwJsdD8u7FIZGL2lH
         DntoTnCUYjnjJNJ2CPu3RCn6bc2UJxVBzc6kGoZbtsTnKUAPjBykcDQm9crhDqfmCYM1
         X5v3Q3830e//69l4ToAJbNsRK/X3N/lumN1sG0o9cGHUWz5epQTR/unI1TA9mmmn2r3s
         6yag==
X-Gm-Message-State: AHQUAubq4g7RtFxRvdlMFcBFsNsBKK+vfxeQ3CCcCnOi8KTKrpWJn/Uq
	gN6SXonDQCDmIANSsNLLqydC4880PjVmos/Q+8Esr3nA7HZZ5CsXA21pHkkanpZXTVdthRic9d9
	pMMqsrWs39bAspPljEEnV9PjhBoRrmbO6qxJKy877ESMd3bJsUSi1FJ6B3BW5te7dgdglJsdW1B
	NWEDW5M6T7eJ9AiyPCwSREFL8BZv3MB9/DTFI8MFG6+ISzsvnt0Tnk738jlUNLiuLSt1i0Fkryr
	NRcOfyTyMFQ+KyA2GITft2oc8P4ctQLBhTdH5pBBCjo3K9CrcYDiqv+E8jU6ZEYe1gFswxv9zL0
	6jyQhrpXymxdGmNADf5h3aphuuZd6s0taiK141irkb9dC7IH2ajCcB+WkVvGoVDRCDo69HPglee
	A
X-Received: by 2002:a25:4e89:: with SMTP id c131mr6460742ybb.383.1550048499006;
        Wed, 13 Feb 2019 01:01:39 -0800 (PST)
X-Received: by 2002:a25:4e89:: with SMTP id c131mr6460701ybb.383.1550048498372;
        Wed, 13 Feb 2019 01:01:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550048498; cv=none;
        d=google.com; s=arc-20160816;
        b=PMmZU1NFGfkLmEA4ijMdyzqGEQyM62Fc9SrgfUKZ6g74SFy87EazIcgrr/LNOiSM4a
         tn0uSLx1o4TT15ZPhOJUSvO8v6MfP1f3mob+9gxsFFA+SuFt5srqScwIcUnJtmSQ6rwK
         ckhpWEhxZyTP5nXdcZW9U3hxltf/4VXY9x4AjJAuxojVoBC0mtNCEASM3uLh7yEKWkgj
         lWrimvVAdYfMc1nDah/QPbVOGt6mqISD4gk4ABCIiFywrb5mF1bsTf8mdlgOF91LrQMf
         DSJUqtD0AkjTydJxSs7K7v7n8NhpX+CzF2kWiWLH6WAj6B+8GtbSTGj0l6Z8/+7I1Igk
         MtAg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=nOxAq2jgYrMbNTBlWFr73Rc+ViApmre//M8IaWoP5S0=;
        b=BmRqwvOt/rk7xjN6s+/rtzcgbHYu0uDhD2VicLSJoaH0HBAZGNSqW9Kk/vpXXGlEat
         SQRffGVhZ+QhFZuCXJ1SEdSukTAVRzUFZxrVcllixrndKG+QY8iAmeCiOwkn9MuSC/Gp
         rz/iNfepu673hm3LxTzprkaag2AMytwvx0PQr12NLBnwP6tSnl8CgSmLW/NGZEdtjKTc
         MX3qFjlDFeMIIaIFjy0Gn2A1Mbubc7vTzZuUAXBh5aFVNNfyrUCroGmlNWok9mn3op2s
         reCFce4cZGNj/wqZLW36+MjkWyYniTCZ/CrFKnRWuJGqLam3+E3XaF6yZpMWJacSkEY3
         YhMQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=VIMY0KrK;
       spf=pass (google.com: domain of amir73il@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=amir73il@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id x129sor7363180ybb.63.2019.02.13.01.01.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Feb 2019 01:01:38 -0800 (PST)
Received-SPF: pass (google.com: domain of amir73il@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=VIMY0KrK;
       spf=pass (google.com: domain of amir73il@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=amir73il@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=nOxAq2jgYrMbNTBlWFr73Rc+ViApmre//M8IaWoP5S0=;
        b=VIMY0KrK4iSNyI1HGmm4jPV9TrQ8QlHaQh+ToWWJjoo8CPj15twvFmLLdUrKhTAEuC
         biSzvOM4rUQMNMRSLiF8FC5/cdnQm8YeFA83kwKe9KrxnJpJ/H1JqWy0QIeMiUnEFmOH
         AoGIq6s8Hf8lnYLG+tbwxlDl3CX3zGKbHSkAvuelpni4+TJUfm3tTR/sEgAK5F7qCN7J
         X+B+k2wB5QutnnTROe8xnwDeO0DIPSvEa3LTswwjR/YISSO4/IgEqSio+8bUdv5vFCCy
         KuM/DtIYgwC5ImjMq7rtXguacejHqDPZc+bsS2Te3hQ0t9AREltbQK1D8ba7bAqaH85v
         k4YA==
X-Google-Smtp-Source: AHgI3IZIW2qaSfMP7UCdKZdSY60xgXrV4aT4hPX+oDKBJgV5JMHXw6PQsG1u07u6EgbYCN/CakP8YSOXqaenfqEulHM=
X-Received: by 2002:a25:9c09:: with SMTP id c9mr6796704ybo.462.1550048497909;
 Wed, 13 Feb 2019 01:01:37 -0800 (PST)
MIME-Version: 1.0
References: <20190212170012.GF69686@sasha-vm> <CAH2r5mviqHxaXg5mtVe30s2OTiPW2ZYa9+wPajjzz3VOarAUfw@mail.gmail.com>
 <CAOQ4uxjMYWJPF8wFF_7J7yy7KCdGd8mZChfQc5GzNDcfqA7UAA@mail.gmail.com> <20190213073707.GA2875@kroah.com>
In-Reply-To: <20190213073707.GA2875@kroah.com>
From: Amir Goldstein <amir73il@gmail.com>
Date: Wed, 13 Feb 2019 11:01:25 +0200
Message-ID: <CAOQ4uxgQGCSbhppBfhHQmDDXS3TGmgB4m=Vp3nyyWTFiyv6z6g@mail.gmail.com>
Subject: Re: [LSF/MM TOPIC] FS, MM, and stable trees
To: Greg KH <gregkh@linuxfoundation.org>
Cc: Steve French <smfrench@gmail.com>, Sasha Levin <sashal@kernel.org>, 
	lsf-pc@lists.linux-foundation.org, 
	linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>, "Luis R. Rodriguez" <mcgrof@kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 13, 2019 at 9:37 AM Greg KH <gregkh@linuxfoundation.org> wrote:
>
> On Wed, Feb 13, 2019 at 09:20:00AM +0200, Amir Goldstein wrote:
> > I never saw an email from you or Greg saying, the branch "stable-xxx" is
> > in review. Please run your tests.
>
> That is what my "Subject: [PATCH 4.9 000/137] 4.9.156-stable review"
> type emails are supposed to kick off.  They are sent both to the stable
> mailing list and lkml.
>
> This message already starts the testing systems going for a number of
> different groups out there, do you want to be added to the cc: list so
> you get them directly?
>

No thanks, I'll fix my email filters ;-)

I think the main difference between these review announcements
and true CI is what kind of guaranty you get for a release candidate
from NOT getting a test failure response, which is one of the main
reasons that where holding back xfs stable fixes for so long.

Best effort testing in timely manner is good, but a good way to
improve confidence in stable kernel releases is a publicly
available list of tests that the release went through.

Do you have any such list of tests that you *know* are being run,
that you (or Sasha) run yourself or that you actively wait on an
ACK from a group before a release?

Thanks,
Amir.


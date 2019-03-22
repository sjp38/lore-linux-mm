Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E7B47C43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 17:50:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A6FF12083D
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 17:50:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="RM4tc1m6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A6FF12083D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 56EAE6B0005; Fri, 22 Mar 2019 13:50:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 51D9A6B0006; Fri, 22 Mar 2019 13:50:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 434F16B0007; Fri, 22 Mar 2019 13:50:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0DCBC6B0005
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 13:50:07 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id p13so1362490wrm.5
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 10:50:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=0vPmacOIS6MqF+i4dB54jdRkG0Jovyo12kSyTo8gBCQ=;
        b=jZPMtfTI9PEsFF151ksu7rjkE39sGq1CVVK5z/ZjBwwtc2FeGf6f9zgGx4nIcH6oat
         KUgVTCdf0WgK6ZUpgNPL5neGS7RXI7DV4mFjQ8pusnCtNM00qVYF7WAJklfRA3zPSfFl
         nx5xmCS3g9jc+SjSzNHClEpFTmbg+ISBazgfCtp4jYIH/x9kgAT67D2CpaTtExKahGyT
         2Ate0nIV0oa619wHR2WZgMfuBcmffxkzquWbecwNQeoVeIPxjQxYuc/5h8qdNVddZVSP
         S3hZS9HBoZMVScsV3zwfVm+g8NZ1/KXH409ZpdLrWlBwm/U2XoNFbCDjKj+GX46x2und
         UjNw==
X-Gm-Message-State: APjAAAUjJ21+EtM2UP+afkPyafJtb8iJfftcqgMCv214BusAdQsrHwNV
	Z06TPsy7SGIjUjxN6q7ms2PiASSzE1t4PhtGalIjQ+7pVmt0VGEP0OJjMik5H6RRgxdSk3CQcJc
	rZKZ7mjxRSg7Hl701C5nHJ0ejE6LEsIXhaqd6mlD2EHCSPjvisAkIUASBnNwzbHgxZg==
X-Received: by 2002:a5d:6406:: with SMTP id z6mr6884460wru.266.1553277006612;
        Fri, 22 Mar 2019 10:50:06 -0700 (PDT)
X-Received: by 2002:a5d:6406:: with SMTP id z6mr6884408wru.266.1553277005682;
        Fri, 22 Mar 2019 10:50:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553277005; cv=none;
        d=google.com; s=arc-20160816;
        b=tqxiW97rSd8eUH6MUdakQkxzlTdkskfI4EMZB2eTI3bJCSJSalMe1g62da8jy0BKtl
         TJO6V7UbEFopiDMTJha/g/n8HAF0ZYJQFgrIEHylBsHQzartfUqNU7pkgUHRhtFtBF9f
         wZ+QchC9XK0N4WKds1jQQEMrCmKtfimh3hzXZm/3ZrHRvo93/Wb6SnQCbqp1nWJulx4g
         /s5l1fsEh+9u+R+yNdW+WF9syOimJhdA2abe07K9EK7XJdBeKeDwihJLOPMJQSurBA8T
         mWOjpg+33NOHYwqSpbcrPrsDkJur9Zn+jb4HjHSWg29Z5Q2Mk4vmmt5fkOzhqXAJjjf9
         Mh9Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=0vPmacOIS6MqF+i4dB54jdRkG0Jovyo12kSyTo8gBCQ=;
        b=SLFfbhwMj+095nup+AH/+PyLy9WNVCj6AqehxTA78kSGBRXgezy9WNvQ7+jeMajD4d
         cUo+enx0InoZ2b0y1suvfhwXT+o6q4XRxgs0S6UsEr5nnVqfABqaOZFkxIk4gAd37uz7
         cBZDdQtztJesq6r3iRJMQNMMZXMGpKYHVlUjOHxdTRttD5lk8kC/WY+Rd0xmGD0w6A4p
         tSmMuP08tfHQ6bs9kaOOL+WLp1VKeR9/bzQqcOtbTwMX8ZNTI+2Fwsw41GDLxSHZBR4w
         jOgUkVz6fvvaw5qJ/T8nykoq86J6b+aUt2F9eF+1pe4wZsynRPSF2+ZT5tdO23rFdLF/
         1hJA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=RM4tc1m6;
       spf=pass (google.com: domain of mikhail.v.gavrilov@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=mikhail.v.gavrilov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id x3sor7101287wrr.13.2019.03.22.10.50.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 22 Mar 2019 10:50:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of mikhail.v.gavrilov@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=RM4tc1m6;
       spf=pass (google.com: domain of mikhail.v.gavrilov@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=mikhail.v.gavrilov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=0vPmacOIS6MqF+i4dB54jdRkG0Jovyo12kSyTo8gBCQ=;
        b=RM4tc1m6rruLzQ4uImq33Yh/t5lT/jzFYdD2BfYrmEYa6x8BpyebZsyNDjONHqXKnt
         y0DqnGhm3dEtnsCfjLcvpTFUhvSLxP80YGhjREjCIvvIWlJFfMOspeRnXIz6go0l1orn
         S5uSdfzxGYCTE8ZhOK5YTpDnsVtn4RoIn1ZCEBqzIKa0cbkM1auF+/vkHp0vmCMMmHKC
         nVBaPAYRJING4qdInJ54Uyh/M25qxvUmED7hhjOQpd+vheI27vV60ggN1k46Vh8Fhkyh
         9frJVQvvGJd9gbKGACOuL7IKYWu0/xP60DuH3AtejVT1FfLKgqm29j7ti+jBTJqpGd+p
         vd7A==
X-Google-Smtp-Source: APXvYqx+Diw80m3Jk/BVKD75tAedmUV/TWsC9okQFtxipkImFR5a+plG7vlACarNipli5UvyJI57pnYxmR2XhN66j/g=
X-Received: by 2002:a5d:69c1:: with SMTP id s1mr8047940wrw.245.1553277004950;
 Fri, 22 Mar 2019 10:50:04 -0700 (PDT)
MIME-Version: 1.0
References: <CABXGCsM-SgUCAKA3=WpL7oWZ0Xq8A1Wf-Eh6MO0seee+TviDWQ@mail.gmail.com>
 <20190322073902.agfaoha233vi5dhu@d104.suse.de> <CABXGCsPXEAfYq3y58hMnXuctUm1D3Md=BpSo=cq5dR9+3aFzOg@mail.gmail.com>
 <20190322085509.hzerxhk5cdewodl6@d104.suse.de> <20190322085624.efa2pdu3shjkjkxh@d104.suse.de>
In-Reply-To: <20190322085624.efa2pdu3shjkjkxh@d104.suse.de>
From: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Date: Fri, 22 Mar 2019 22:49:53 +0500
Message-ID: <CABXGCsP+iWpsWZw0wKMFh2tqpyLAXYT6tpvCmmNH=HKmw9JgWg@mail.gmail.com>
Subject: Re: kernel BUG at include/linux/mm.h:1020!
To: Oscar Salvador <osalvador@suse.de>
Cc: linux-mm@kvack.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.007126, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 22 Mar 2019 at 13:56, Oscar Salvador <osalvador@suse.de> wrote:
>
> On Fri, Mar 22, 2019 at 09:55:16AM +0100, Oscar Salvador wrote:
> >
> > Thanks, could you boot up with below patch and send back the log please?
>
> I mean to send back the log once you trigger the issue again.
>

[1] https://pastebin.com/wLdmg3a4
[2] https://pastebin.com/74BThYCf
[3] https://pastebin.com/ZKBzGCTx

--
Best Regards,
Mike Gavrilov.


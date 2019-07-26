Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E9F59C7618B
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 11:49:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AEC38229F3
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 11:49:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AEC38229F3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 598136B0003; Fri, 26 Jul 2019 07:49:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5488D6B0005; Fri, 26 Jul 2019 07:49:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 436806B0006; Fri, 26 Jul 2019 07:49:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 229486B0003
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 07:49:30 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id m198so44839264qke.22
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 04:49:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to;
        bh=i8wjsn/J7AjCMbxusJs+A5ywmyPLK0X8wVGP+ZIy8uY=;
        b=IES4pLUmbk2y/SdVt7Jke+jv8nkIMhUY0xXIy1nedZWu+kgyVJVlU2+m5YPwa086+E
         jnwmf9iq72zDJH7H1/HVCYd+2I9v5oEaOCOiWfWKYLJfhgyQQAQFd/MXq1OIUoK07lkr
         Y8etzJWARf8U4eR77UmZf3dB0h8vMoUbBBQxlWwli3DwKIBk9d0nQ+oc/peeYgsKaOy8
         VunNQtq6tDBKGlzZXkGcdC678bM15Zus1MdAIRFncJNbfjD8+XyltF6Cx6BWYGeRzAhs
         6yV9mqHvMGnQAtBdSn6YtsalOch7CGZ1EmfvYz7cEmmte+hc+8X3R0xmGuH6B5jg3ArU
         y4Kg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAU2Ia64PV6Gi8qnz3HRpAqqC3d8VyvfNeSp9qvMS3PezSOPBZgH
	4vyN0+sLbjMm75NlaLPzbu4o9a4RHKmMf9qDoBPI9N7qoWIAcsI51pbZpnLhcMpCmxxGyzP+JB5
	MOHp2BCIDYkeNCrV7bkZIvdlJDS7l2jxF3TMsJfM9Ti1Z3E/1aytnddRiTYrWxxfPIg==
X-Received: by 2002:a37:a116:: with SMTP id k22mr61955143qke.53.1564141769929;
        Fri, 26 Jul 2019 04:49:29 -0700 (PDT)
X-Received: by 2002:a37:a116:: with SMTP id k22mr61955126qke.53.1564141769416;
        Fri, 26 Jul 2019 04:49:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564141769; cv=none;
        d=google.com; s=arc-20160816;
        b=G7vV3NVDWhPhqxQOYhDq0lPDMC5IwGtyWa4mXCgORYDwi/F5lpYgZigpW2kxIiwSdA
         KW6vm3Ef/4t3+zrliGFz/knopCPUh2wvdevQYaY0PirNSrpprVQezG+stf8V6oV6FUP6
         3G6G1qMLdKf8sG2sGHpA/Vhz+SO669p6DyIxIB/391jRxm/ctqYreoYRtkVBOdZ6z81z
         g2wMg0e7UJvV9Yzcxg9gu6F0DVJAC5FzAM9zbCD4R/Q/5apgluiO47Qa+7Sx5UDCQRmL
         xqIZ9FTGPors0jcxjTD2COa+8LcHs1b/SxWpa7jBE+pqpMB8TNQLdG5aX8QOj7o6JD26
         6IgA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-transfer-encoding:content-disposition
         :mime-version:references:message-id:subject:cc:to:from:date;
        bh=i8wjsn/J7AjCMbxusJs+A5ywmyPLK0X8wVGP+ZIy8uY=;
        b=TKSsTxsKK+eaggVr+Aw2/nISoSlNBQg6lTxuuXIV0qww9OGejp6jc6Vb5Dqam5gu7h
         WtdnRRxR3jYAHPDB7jnUjGikefOTuJnwOU3YMi/8GVUIBGMk6Kd0hqPgDXEKDKVoAvmD
         fJ+peboAdT5j+yHquKHAuNuTSyM1KAAfxKRdW5ddMK78qnGoOWTz5F+/HCQnqNhR8nmE
         ncCZBdS1SWKSH5rMgbCv5KMgyPDj2Nutb4JrQm/VIQ6msqwrOimyCjQniy8UnMN3vvxi
         oH1WuCYeSP7YqATN3EMxtPHKhHfQLbj7yW4e52LIABZaDOhHyTqih3YdD9FepwR/Sbmi
         6ccg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o10sor69354190qte.26.2019.07.26.04.49.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 Jul 2019 04:49:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqwMsTGjfM7uQAnObrU4lf6ZCQqoJiT3HpWwMpyDoRsBS/oRMj++843f20ueHHr8c24KKPsFiw==
X-Received: by 2002:ac8:32e8:: with SMTP id a37mr66953459qtb.231.1564141769219;
        Fri, 26 Jul 2019 04:49:29 -0700 (PDT)
Received: from redhat.com ([212.92.104.165])
        by smtp.gmail.com with ESMTPSA id f14sm21725527qto.11.2019.07.26.04.49.22
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 26 Jul 2019 04:49:28 -0700 (PDT)
Date: Fri, 26 Jul 2019 07:49:19 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Jason Wang <jasowang@redhat.com>
Cc: syzbot <syzbot+e58112d71f77113ddb7b@syzkaller.appspotmail.com>,
	aarcange@redhat.com, akpm@linux-foundation.org,
	christian@brauner.io, davem@davemloft.net, ebiederm@xmission.com,
	elena.reshetova@intel.com, guro@fb.com, hch@infradead.org,
	james.bottomley@hansenpartnership.com, jglisse@redhat.com,
	keescook@chromium.org, ldv@altlinux.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, linux-parisc@vger.kernel.org,
	luto@amacapital.net, mhocko@suse.com, mingo@kernel.org,
	namit@vmware.com, peterz@infradead.org,
	syzkaller-bugs@googlegroups.com, viro@zeniv.linux.org.uk,
	wad@chromium.org
Subject: Re: WARNING in __mmdrop
Message-ID: <20190726074644-mutt-send-email-mst@kernel.org>
References: <20190723035725-mutt-send-email-mst@kernel.org>
 <3f4178f1-0d71-e032-0f1f-802428ceca59@redhat.com>
 <20190723051828-mutt-send-email-mst@kernel.org>
 <caff362a-e208-3468-3688-63e1d093a9d3@redhat.com>
 <20190725012149-mutt-send-email-mst@kernel.org>
 <55e8930c-2695-365f-a07b-3ad169654d28@redhat.com>
 <20190725042651-mutt-send-email-mst@kernel.org>
 <84bb2e31-0606-adff-cf2a-e1878225a847@redhat.com>
 <20190725092332-mutt-send-email-mst@kernel.org>
 <11802a8a-ce41-f427-63d5-b6a4cf96bb3f@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <11802a8a-ce41-f427-63d5-b6a4cf96bb3f@redhat.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 25, 2019 at 10:25:25PM +0800, Jason Wang wrote:
> 
> On 2019/7/25 下午9:26, Michael S. Tsirkin wrote:
> > > Exactly, and that's the reason actually I use synchronize_rcu() there.
> > > 
> > > So the concern is still the possible synchronize_expedited()?
> > I think synchronize_srcu_expedited.
> > 
> > synchronize_expedited sends lots of IPI and is bad for realtime VMs.
> > 
> > > Can I do this
> > > on through another series on top of the incoming V2?
> > > 
> > > Thanks
> > > 
> > The question is this: is this still a gain if we switch to the
> > more expensive srcu? If yes then we can keep the feature on,
> 
> 
> I think we only care about the cost on srcu_read_lock() which looks pretty
> tiny form my point of view. Which is basically a READ_ONCE() + WRITE_ONCE().
> 
> Of course I can benchmark to see the difference.
> 
> 
> > if not we'll put it off until next release and think
> > of better solutions. rcu->srcu is just a find and replace,
> > don't see why we need to defer that. can be a separate patch
> > for sure, but we need to know how well it works.
> 
> 
> I think I get here, let me try to do that in V2 and let's see the numbers.
> 
> Thanks

There's one other thing that bothers me, and that is that
for large rings which are not physically contiguous
we don't implement the optimization.

For sure, that can wait, but I think eventually we should
vmap large rings.

-- 
MST


Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0B3A3C282D7
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 17:52:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A6BE32087F
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 17:52:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="dOHMTovA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A6BE32087F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 175968E0003; Wed, 30 Jan 2019 12:52:27 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0FD558E0001; Wed, 30 Jan 2019 12:52:27 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F08C88E0003; Wed, 30 Jan 2019 12:52:26 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id BC06C8E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 12:52:26 -0500 (EST)
Received: by mail-yw1-f69.google.com with SMTP id d72so200595ywe.9
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 09:52:26 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=nqKoowBhVNotvsktwsU7UZYX3ZVWVurI0845PhIUGvE=;
        b=q3pvrB7SlmTz/8AC3ftDVta9tv5IfFCD6LhaTG6Rpojq2IoajkgSkZCBHBi4/gtj+4
         YKW62ds9Vc2yY7UEh45Mli0ih0qB6t/tcOvlnShIoirsE3LQ8gCWwN+NS76uFmKICUkf
         m9dU0xOQV7KXJk6f+fUe7GWJOrzrePoA8b6jWt5XJRh7g7E59jVPqfFsRGEnTzm0sMyb
         jMBB6nnXGw3SfhPU3cAfHEELQY9wcGWpXMWNrgSt8CT+/X8scjkZ80+N6vsUoQ40w5uj
         JVCIRL7mTbg6QV1rv0B7CR4LHNTQPal0KuFfE1dwjgtSOkeOVM6798L4fSXqIc9jpklt
         jG6w==
X-Gm-Message-State: AJcUukcoRuWz7YLESko5NrgIn1SIYDTlGzYy6EBrT1NWlbtNOmkqRFzr
	ZYS8sLJH6KreDN7iNwAbuSAG8pelW9TBuEle2O7l5KLo41SROGzYZycRzeNyAXnXigahUVBfRMb
	qucQOEvPoqIl/YaxAkoxzB2NWfBUwctF+5QITUg1bonxc1SwDelDhGypWGQ6JKyxFUstAmvqBw4
	dkfSSzJqxfbOxOayWw9gjm7bmId7jtXVb4Yb9BIeaiqoSwHqntxT5WnopBWimxNBZBvUywLWMiA
	cwUy5cHPMs9u6+vBtLeYHl3Bt+JmIGjeDRM8Dd0NS9L7ZYKuur51Vyud2eyhOsL8027NWdNyuoS
	s3q5FWHoRaBigKSdB4p65K8Hv+SwgMpg2k5VHFnznOKd4k/tYMgByXwzoIxxB4D3xvqoVKyPCA=
	=
X-Received: by 2002:a25:3bd7:: with SMTP id i206mr29534279yba.145.1548870746486;
        Wed, 30 Jan 2019 09:52:26 -0800 (PST)
X-Received: by 2002:a25:3bd7:: with SMTP id i206mr29534248yba.145.1548870745933;
        Wed, 30 Jan 2019 09:52:25 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548870745; cv=none;
        d=google.com; s=arc-20160816;
        b=UOdB+nPdgb24Tj4p1ozMkePcjHnR5cNvQh2erkPNjw8uYEN93aExmgXS+r4WMHB/XP
         9yaKr06ZLgUASCRuJUNTts7uhiZa2xoqUsOitENQBtR15//2iwLoxrWnfgH+IMazoLaY
         8U1WCTPY+LyOWJf41HUu8hC4gCVyHww/M4p8+BQjZ+UOmTDkxI3RZ7Kwwl8RoVJ9rt8v
         N6w8+/Sk+ZmiA9D0AM9ww30c63+espftHm006NAL8X4nS/EGZiM/RLUKEnt3xB8tE2XR
         Ii8Cv9zQQEqXHhB9BwqlU9+djH0BwrIwjIlgSegXUUF1BKvgiDnb6NbCD2vt09ZGX7Sn
         1aHw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=nqKoowBhVNotvsktwsU7UZYX3ZVWVurI0845PhIUGvE=;
        b=b1K+U0qVRnrKaovqPhqc1qL+lZeTvZvZXGeQfMRl2316NPylSJU9YBPGmlwsyXdGZz
         WdU6YsCoTZWIPXGX4ZfAmPNcMYFvF4uyOnLJsgW366hRZLbWDjn0dyLNXCbSc9oDOsB2
         Z80GIuBJRjdu3q28R57ftzQsZeG4uwZtI+MaitdyPXgobwVpfytK37PaC6GoKknVqzYO
         +Ka9r7SxXlEP91l/wBsxLy2JJvXaCRM/pVzmp1YJUQKFm0+SjSqQWqey+mvBsErky0sR
         lRS16wRX/JAPmqLGgqjjxaYrVX6dLICK8P2zV9IB4eW77nOcayAlKrLdXniqWo3uQuki
         KSpw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=dOHMTovA;
       spf=pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=htejun@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w82sor965852ybw.32.2019.01.30.09.52.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 30 Jan 2019 09:52:25 -0800 (PST)
Received-SPF: pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=dOHMTovA;
       spf=pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=htejun@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=nqKoowBhVNotvsktwsU7UZYX3ZVWVurI0845PhIUGvE=;
        b=dOHMTovASZbHyzLMlsR1yiUz4PRvp4/poseV7ogwNMHv3/be5mx/yokv2EEwmfpd7T
         FK/vMQcx4rU01+ILFFvVnmT19udKPJH0GBaWw3rzZ/59IhlxxwYzXEjCGPx8j4W0slD5
         8mjqVJfR0n0h5oQFJ8Bj6WXWQd8hUGp1Pslh3smiu/WkeKL2wL8B4c5hxR30r+V9KW61
         kO99vj4we+fQpeuEG3HgawSzwpSgLCBWejrCgd9CsRY1nniS3gTUf6b1YaunN5R0cS88
         +9Gud7dyuD1S4gO7Z1GHVUnIdEahBP1feMONom808xwfS7aH2Rws+RibtI316+umNGgI
         NpIA==
X-Google-Smtp-Source: ALg8bN628JXeckvdJGB6xWOnV6HxuTUUu+k4Hb31FKkRaVS5OQhGSk9ocEMHOqrY6prvD44HHm13xA==
X-Received: by 2002:a5b:98b:: with SMTP id c11mr22918439ybq.141.1548870745339;
        Wed, 30 Jan 2019 09:52:25 -0800 (PST)
Received: from localhost ([2620:10d:c091:200::7:e55d])
        by smtp.gmail.com with ESMTPSA id s35sm3839343ywa.19.2019.01.30.09.52.24
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 09:52:24 -0800 (PST)
Date: Wed, 30 Jan 2019 09:52:22 -0800
From: Tejun Heo <tj@kernel.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Chris Down <chris@chrisdown.name>,
	Andrew Morton <akpm@linux-foundation.org>,
	Roman Gushchin <guro@fb.com>, Dennis Zhou <dennis@kernel.org>,
	linux-kernel@vger.kernel.org, cgroups@vger.kernel.org,
	linux-mm@kvack.org, kernel-team@fb.com
Subject: Re: [PATCH 2/2] mm: Consider subtrees in memory.events
Message-ID: <20190130175222.GA50184@devbig004.ftw2.facebook.com>
References: <20190128145407.GP50184@devbig004.ftw2.facebook.com>
 <20190128151859.GO18811@dhcp22.suse.cz>
 <20190128154150.GQ50184@devbig004.ftw2.facebook.com>
 <20190128170526.GQ18811@dhcp22.suse.cz>
 <20190128174905.GU50184@devbig004.ftw2.facebook.com>
 <20190129144306.GO18811@dhcp22.suse.cz>
 <20190129145240.GX50184@devbig004.ftw2.facebook.com>
 <20190130165058.GA18811@dhcp22.suse.cz>
 <20190130170658.GY50184@devbig004.ftw2.facebook.com>
 <20190130174117.GC18811@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190130174117.GC18811@dhcp22.suse.cz>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 30, 2019 at 06:41:17PM +0100, Michal Hocko wrote:
> But we are discussing the file name effectively. I do not see a long
> term maintenance burden. Confusing? Probably yes but that is were the

Cost on user side.

> documentation would be helpful.

which is an a lot worse option with way higher total cost.

If you aren't against making it a mount option (and you shouldn't),
I think that'd be the best use of time for both of us.

Thanks.

-- 
tejun


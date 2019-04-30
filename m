Return-Path: <SRS0=8Dof=TA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 68A33C43219
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 09:08:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 254E720652
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 09:08:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="KCIillAx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 254E720652
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B2AFA6B0003; Tue, 30 Apr 2019 05:08:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AE4606B0005; Tue, 30 Apr 2019 05:08:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9C9F86B0007; Tue, 30 Apr 2019 05:08:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3BA086B0003
	for <linux-mm@kvack.org>; Tue, 30 Apr 2019 05:08:11 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id u5so2637193lju.22
        for <linux-mm@kvack.org>; Tue, 30 Apr 2019 02:08:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=9HjQ88MY4ZiDc1bI5n4MIBBh4bZ2A3E/q/QZEBk7alU=;
        b=sTVPAEp5e2pbUu/E8mVgRl03soyF5mwW8+4B5Vc1qSuJ/UlknpYXHHFAUir9WNlxFT
         omlVZJU4uGTvwB4f/3A9zD+Tmwcn2ZKAF3w5CCvmWdE/X2AcjN/2ijmeU5Z1I5alb5UP
         qbeu73kalZXDTp3m8HzOLME1xwPhRZbsBH8+n4k5wjI9N3/9RhysW0K34AfA2GQEmB3+
         so4CkAidLa5/smhAGBpkOwYwKLPfX4/+AH+LMV6oBSS9npruxmxzvcV5+34ZFMYv+QDi
         ELQHKsv6S69/X8khVr+Bqh5JiPDiFPpttEu/v7lTZ5JM/lXWfnOBUe6hNudnGc7GSHGR
         Hc8A==
X-Gm-Message-State: APjAAAXl4caEAxfC9fqpx/zwXBmwXCaJfYIWJff8LX/tGj4RL59qPTS2
	xrSJQvgxKEIoP/pzuLM6yonZdwfJjP9fKGUGt1wERZSys6hDhNHHaRj+3yoVMqKFpUqqc4L7ItD
	xb2baqvLJggH2vxf6G54XA9va1N/sYSHh9VWD3LS9lmNidWP92Fmn3TtRz9KvGwI29w==
X-Received: by 2002:a19:f703:: with SMTP id z3mr35145895lfe.119.1556615290554;
        Tue, 30 Apr 2019 02:08:10 -0700 (PDT)
X-Received: by 2002:a19:f703:: with SMTP id z3mr35145862lfe.119.1556615289776;
        Tue, 30 Apr 2019 02:08:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556615289; cv=none;
        d=google.com; s=arc-20160816;
        b=hdqbybzafv1rcOiULe2woSqJo5L5y51+6R1vUzLsSIF8aW/3KRRJkuFsU8cNPJgUh2
         R7BVymwSR5oE45qT72eZb5d3U49W8Qw+1E/Aeby7HtwYNhD6b8Bk40YqhO8Sy8LPrakQ
         bMFpjzBwZCfWvdz+zB1AqhxcvgK8+7CHL87Xhx1E9PRvZjelf0G5wmRUtoFN3qG3BXJa
         cmmfTq1gLbxjpfw7gU53OfBbXgl2EeDr+aOnXpd7iq5AW+YHU+vayTOp0MzAITq+jVpa
         MKbFw5RexzZn+fz6jY+5dJchvldS3R+1QvLZvX7BEwwHFVzfc40n3alLoleVwhaegGcz
         j8lA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=9HjQ88MY4ZiDc1bI5n4MIBBh4bZ2A3E/q/QZEBk7alU=;
        b=BZ39Tf/Wz6428ZlOerh87xLh9uuiCairqaQwfdt/vqoqF8pkGkYWBMUpqZNSu+HYU7
         1cABHzFuM83gUXDEJaBQEY9KZM4s9Mort3kk25jxZhb6NgUKtj78YJqVuEJ2X1WSmf0r
         GZGtEXwVPbA5SS3nrTCEPeitHSPzSGApH7WVpg0G4Ta0mlwBVshr5hz9xN0hMxgm97tK
         nJvq+nCGsnmQrrGHiz0y9aprXTqSyxIDLWfJPfSkApWOjanCT/O9eBLp06Q2EQ+bpPW2
         H2+sDGc63FfMv3q5RTBhbQV/HmfAFI1WBbvtIGj32SlwhU1rOkXUgE8msKxtpzwiS6r2
         iACg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=KCIillAx;
       spf=pass (google.com: domain of gorcunov@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=gorcunov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y125sor7475297lfc.63.2019.04.30.02.08.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 30 Apr 2019 02:08:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of gorcunov@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=KCIillAx;
       spf=pass (google.com: domain of gorcunov@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=gorcunov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=9HjQ88MY4ZiDc1bI5n4MIBBh4bZ2A3E/q/QZEBk7alU=;
        b=KCIillAxrZrXB5w7B79fb19nYg7F3YCwf/ztmA9aoE9VUD7WLkEyGA1XTGj7Kk7I9I
         Q513ZwfxLRI6HJ4DrN1ZMjXfa842QSSs6yPwd0FUt+xZKwllptZpyag00LUFcGYK3EsC
         XdEbFchQbx1GNf/krTIlE74LPo3MefjF2xV0uZ5Rt9BcNTBf/J2/0tgE/CjrS+/46uwD
         ARjeDWBBqlnHHRKTKdiGH05RWZ9Qh2z5qOAaNQx9+9uWyCnSM+J6HGsn9mtkAkyisNb6
         WLz5Pn17WNGE47oaQuTDdvGZvJ9oPYfrIEusa3M0SiUmfS8nh2ODl35nGOliRsB/77U5
         zOrQ==
X-Google-Smtp-Source: APXvYqxC1zZd7LprV/dgF44Ba5ne0SfC/5gxd6UPTeJBnWPoKvFHoqjjCKTMw2d90XkBC0hQgb2Gkw==
X-Received: by 2002:a19:f50f:: with SMTP id j15mr36291099lfb.135.1556615289352;
        Tue, 30 Apr 2019 02:08:09 -0700 (PDT)
Received: from uranus.localdomain ([5.18.103.226])
        by smtp.gmail.com with ESMTPSA id u22sm1374696lji.40.2019.04.30.02.08.08
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 30 Apr 2019 02:08:08 -0700 (PDT)
Received: by uranus.localdomain (Postfix, from userid 1000)
	id 45A444603CA; Tue, 30 Apr 2019 12:08:08 +0300 (MSK)
Date: Tue, 30 Apr 2019 12:08:08 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: Michal =?iso-8859-1?Q?Koutn=FD?= <mkoutny@suse.com>,
	akpm@linux-foundation.org, arunks@codeaurora.org, brgl@bgdev.pl,
	geert+renesas@glider.be, ldufour@linux.ibm.com,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org, mguzik@redhat.com,
	mhocko@kernel.org, rppt@linux.ibm.com, vbabka@suse.cz
Subject: Re: [PATCH 3/3] prctl_set_mm: downgrade mmap_sem to read lock
Message-ID: <20190430090808.GC2673@uranus.lan>
References: <20190418182321.GJ3040@uranus.lan>
 <20190430081844.22597-1-mkoutny@suse.com>
 <20190430081844.22597-4-mkoutny@suse.com>
 <af8f7958-06aa-7134-c750-b7a994368e89@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <af8f7958-06aa-7134-c750-b7a994368e89@virtuozzo.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 30, 2019 at 11:55:45AM +0300, Kirill Tkhai wrote:
> > -	up_write(&mm->mmap_sem);
> > +	spin_unlock(&mm->arg_lock);
> > +	up_read(&mm->mmap_sem);
> >  	return error;
> 
> Hm, shouldn't spin_lock()/spin_unlock() pair go as a fixup to existing code
> in a separate patch? 
> 
> Without them, the existing code has a problem at least in get_mm_cmdline().

Seems reasonable to merge it into patch 1.


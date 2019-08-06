Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=1.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 460A2C31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 11:07:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D004E2173C
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 11:07:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="FKiohG4p"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D004E2173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 340806B0005; Tue,  6 Aug 2019 07:07:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2F0806B0006; Tue,  6 Aug 2019 07:07:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1B9456B000D; Tue,  6 Aug 2019 07:07:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id DCEF36B0005
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 07:07:48 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id a20so55662534pfn.19
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 04:07:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=tBmS1JSg6R7dIdS7tcKHXNzn/jUBrwmVmbb/LUzYkA4=;
        b=OGp0+8OJ9H9d7y1eHeuzf5qwnnjg4YN94U3e3QDbYWfbFsWyBPz4sb3nFQs7v76hhM
         mweD0kddY4e0TbNH0gqjZ2DRI+PubLrBLcUUySEJQNO6gmjxlJ8SSOBxkixt+KxU+kti
         ju33kf+hq/4CsiZOU0BHsDJOdvOLMFBdb2zdwPIAY3RztvbckDJEJb6hkaEMucriF4Ju
         OwivAJoXuP0NexQWw/HKz7p1Kdd4F09aHmpAUtycNiod86GaEOlwk/hreZsGQD/r5RgA
         bAwXSS12ySNRv+vt7Kp7A0dhxxTg24zWTTtr2pv41epR05jd6ANGb1LhJT6c836tE9i5
         pAUQ==
X-Gm-Message-State: APjAAAXr39ffikL9AOGpwetv8jNk66SIPN0BIHjd7zmNVl/DU4hfN4B9
	yoHrgY7PcQ0OR6ypYXIZxymQ8YJAOQV0LzZW+IML2sZqjvFKOqzQGbrx7ciQmewccl+WuzJcFmn
	QZi/wpUjbOTC45YQ4yOKUonTCmM8dbwwlfHlLI2eft0N15cQ3lLHzZ8dVNTSm0RI=
X-Received: by 2002:a62:e315:: with SMTP id g21mr3142348pfh.225.1565089668569;
        Tue, 06 Aug 2019 04:07:48 -0700 (PDT)
X-Received: by 2002:a62:e315:: with SMTP id g21mr3142303pfh.225.1565089667981;
        Tue, 06 Aug 2019 04:07:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565089667; cv=none;
        d=google.com; s=arc-20160816;
        b=BGF9BvtfvoU/mZpi+VILEmZsjFKn85aqknL8+7Wjl2SRrHYkOpSxYXvHHOlhSoVPs8
         iGnQUtshn3uhK6Ym+np17H/SIU/mQHBIqbWS+3bzREG1dl/NwdSjhMJanNDr8UrbFfHE
         z8kTkf2rGQV4aqeb1pEC8ONlBw60rvoevIpyd+Opy1wguh/1Y6dGJsxUxEy6N2mEyczo
         aOdth6XYtQu2FO+LuVv97PQ/IzCj10ml3+5fBw0Ned+ty3mGCCQGZqRCK/9kf287N3dn
         c3gfxv1Qv7fI3XOUOwrsWW0gCaGge2m6FZ+WPQPsULTZau3r8KP+uiTEaAvEGGKLpxc+
         mLdA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=tBmS1JSg6R7dIdS7tcKHXNzn/jUBrwmVmbb/LUzYkA4=;
        b=tgAc7fbWZRJsA2zhPaTkEtGhQfCphETGX6mpCYC7R44uc1penhH3Zotue7/Oly9uZB
         3dSYgsF99SQs6OeotrUT1NPZD9WMBceEM0lA4oLXVWpzeKfQS4vORDMHctHpvkDk9xhW
         XD9+SPR4M5yCQG1T3+fpLS7As9uJ5iAPtVNw+M75783JAglWRlz1VNqQQac1W0rHuru+
         sscHy0tsUBQXo+tuK7IXOfqt/bjYL2ITNMMqm+yB7CxC7JyxacDpDKHzP05ajBunKBV+
         gX9azxn0AOYvFKLSEaLD3I4KUH7X4GhWWybXw7mWBSjGOHwLuW3pLpa3aJ+hI6zeLfhu
         GisQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=FKiohG4p;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f7sor68381969pfb.22.2019.08.06.04.07.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 04:07:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=FKiohG4p;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=tBmS1JSg6R7dIdS7tcKHXNzn/jUBrwmVmbb/LUzYkA4=;
        b=FKiohG4pWZeA/Wi7DBC/9npqkDrHpyRoEZz0rJr3UUucKs69b2m0OSmC0nKoqoEBW7
         5a5fisl81W7ayWltjhWVDhYcauX5oI8qjT4HtPAD8MYvTTn2BUR7Z+/ra9jmsBm5ygxl
         coLvx5hCepcasDv3Ne7A33Zn9x+18/WPTkwpxyTWKXEQavMv1FfQZWEk9n3vFCWxJKBz
         8xgjqJToD3aUbClZjNybApCSYfWR+J9s7Cr5z2gCs2zn7kfaA/XDfENps51XKzcC7h+v
         MMuNw3N9Qr5VXXVcVPES+JzklSH8uO3a+z/VBP70OotlcR+ykPpu1CCL5PGcPfSbf/4h
         l5DA==
X-Google-Smtp-Source: APXvYqyN06dee+YCHt2A2RzCyf1hHdHxVyVKw3mol+ZH/H3Wfu7dAX7tuJm7I+hqEodTVg3369khvw==
X-Received: by 2002:a62:3895:: with SMTP id f143mr3075201pfa.116.1565089667635;
        Tue, 06 Aug 2019 04:07:47 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id h129sm82492287pfb.110.2019.08.06.04.07.39
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 06 Aug 2019 04:07:46 -0700 (PDT)
Date: Tue, 6 Aug 2019 20:07:37 +0900
From: Minchan Kim <minchan@kernel.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Joel Fernandes <joel@joelfernandes.org>, linux-kernel@vger.kernel.org,
	Robin Murphy <robin.murphy@arm.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Borislav Petkov <bp@alien8.de>, Brendan Gregg <bgregg@netflix.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Christian Hansen <chansen3@cisco.com>, dancol@google.com,
	fmayer@google.com, "H. Peter Anvin" <hpa@zytor.com>,
	Ingo Molnar <mingo@redhat.com>, Jonathan Corbet <corbet@lwn.net>,
	Kees Cook <keescook@chromium.org>, kernel-team@android.com,
	linux-api@vger.kernel.org, linux-doc@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
	Mike Rapoport <rppt@linux.ibm.com>, namhyung@google.com,
	paulmck@linux.ibm.com, Roman Gushchin <guro@fb.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>, surenb@google.com,
	Thomas Gleixner <tglx@linutronix.de>, tkjos@google.com,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Vlastimil Babka <vbabka@suse.cz>, Will Deacon <will@kernel.org>
Subject: Re: [PATCH v4 3/5] [RFC] arm64: Add support for idle bit in swap PTE
Message-ID: <20190806110737.GB32615@google.com>
References: <20190805170451.26009-1-joel@joelfernandes.org>
 <20190805170451.26009-3-joel@joelfernandes.org>
 <20190806084203.GJ11812@dhcp22.suse.cz>
 <20190806103627.GA218260@google.com>
 <20190806104755.GR11812@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190806104755.GR11812@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 06, 2019 at 12:47:55PM +0200, Michal Hocko wrote:
> On Tue 06-08-19 06:36:27, Joel Fernandes wrote:
> > On Tue, Aug 06, 2019 at 10:42:03AM +0200, Michal Hocko wrote:
> > > On Mon 05-08-19 13:04:49, Joel Fernandes (Google) wrote:
> > > > This bit will be used by idle page tracking code to correctly identify
> > > > if a page that was swapped out was idle before it got swapped out.
> > > > Without this PTE bit, we lose information about if a page is idle or not
> > > > since the page frame gets unmapped.
> > > 
> > > And why do we need that? Why cannot we simply assume all swapped out
> > > pages to be idle? They were certainly idle enough to be reclaimed,
> > > right? Or what does idle actualy mean here?
> > 
> > Yes, but other than swapping, in Android a page can be forced to be swapped
> > out as well using the new hints that Minchan is adding?
> 
> Yes and that is effectivelly making them idle, no?

1. mark page-A idle which was present at that time.
2. run workload
3. page-A is touched several times
4. *sudden* memory pressure happen so finally page A is finally swapped out
5. now see the page A idle - but it's incorrect.


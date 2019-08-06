Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E8350C433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 13:48:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A6850208C3
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 13:48:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=joelfernandes.org header.i=@joelfernandes.org header.b="v5SqwqpA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A6850208C3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=joelfernandes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2EEDB6B0007; Tue,  6 Aug 2019 09:48:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 277276B0008; Tue,  6 Aug 2019 09:48:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1189B6B000A; Tue,  6 Aug 2019 09:48:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id CE1B36B0007
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 09:48:57 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id u10so48367000plq.21
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 06:48:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=UkgbsLvaM9M+9IVDtc/oOOdmfQ/azKwIM6sOgM9Uo6A=;
        b=XVYacHxiKZe9kmdYm1LVKSpwfMcVFa563VpoC7fCFx3bevuCPH5aHW/Olyp8TWuuUE
         UICWWSdEuGWtLK7OHdHFNZYid1iM9WFD0v1Lyy6OtxOsxoWLs6ty1Zii3OcKvH2wG3HZ
         nFfwDy3YgHS7YUjaDPima5hkgFb2R3qGWI23YrGXzSiH9hBRzbwxtkSojp1f8y3I8sj6
         zl6F6eCqVaN8vvAkbf1Z2US9Hx7sYJ4/x2T6AurDr7riufgsOmV6zyFd6XA5aqX8VUid
         Q4b0Fh0waFhFpCBJ1HmrhOYr+9LrTpk11C7qOLEOQAWxacXzgQ75lN3+GfE+MDqubJ94
         XPNw==
X-Gm-Message-State: APjAAAXL80UXz1afvS7nY3oQli78fk8f23UJaZ2DcuPLW6hhPLN/E/oC
	Augl/WuuoYCzTV7RFrOmEdX+Iwb1bEg7mgUWgL3K1TV+n9abfwt66/Iz8UF9tEO9oqSYj757/hy
	xJLFMCp0RvbEUavjSreVePArg9+Egnq/EahVWdnpRgbNUD6NPUgNPEu7oe7OJD0NbSA==
X-Received: by 2002:a63:d30f:: with SMTP id b15mr3091188pgg.341.1565099337328;
        Tue, 06 Aug 2019 06:48:57 -0700 (PDT)
X-Received: by 2002:a63:d30f:: with SMTP id b15mr3091144pgg.341.1565099336521;
        Tue, 06 Aug 2019 06:48:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565099336; cv=none;
        d=google.com; s=arc-20160816;
        b=n1Z+XcOo6FFOGxIRvawawQQD2wwTmndTYdFrDFIE40diSF9zSWPPgThXr67CPxJ/pU
         Qwnthew7QMUS7wE8ACk0ZI+VrW0lLFms+WHmZF9ImHLMIuJhpldpMv+rOXT0KcNP4kiW
         9gJD8iBU0JABGP5iGAgRBWkghBSklLrzmJbFWsneaQTAhc2PKkifJY3pM2ER7KoN3nW7
         LWePWywOwAZ+JfG9eliyNYm7DVWpwFWrfVY1XELHd0Q3QlVfsI4ThZ9gO4ca+py+kfjc
         tku48ubC7Yeg6zCsWloYNsgilr2BaLHRAUI41Y0HH6FfAdZCdgNxsHevswE48UjeDRtJ
         iidw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=UkgbsLvaM9M+9IVDtc/oOOdmfQ/azKwIM6sOgM9Uo6A=;
        b=U157/MaY6enYp/txaBwS0A8VRss0l2lO93gnjaKWS+NwjQ9A3l+KhJbDT+ndyz8wFJ
         pQ7xQTvsPU3frlFcfQ2b/NGMilhGqGhAZlG7jONtYfZ5lN4JNcRptMyVciFqyildXrM2
         2W15Yx+rBuuy8j597SkkMcxhxr8jdS6qM2RZyaaPle7nkIwnMel8gyypiAG41IEnNylM
         LC/XdVufJyxUgQbsVjpK1MefwwGKUBG2u9hinA8IrQGNAgOuYOhp5ho6P34gU0LF3dgZ
         /hM9Ko/74wcJuG08R+LVChDCcp/FvVdFke6uAMx7PuVs+HF02fQqYzG6z+tdWaImZtt7
         o2aQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=v5SqwqpA;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n6sor104313241plp.9.2019.08.06.06.48.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 06:48:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=v5SqwqpA;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=joelfernandes.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=UkgbsLvaM9M+9IVDtc/oOOdmfQ/azKwIM6sOgM9Uo6A=;
        b=v5SqwqpAWWpP6genLek7yXSgtt0oPKJl2yiJUqIkB+Hk2eUQj7QLyIcD1XsDGstAc5
         IJkt3gp1qpEOfjNBQpPOwAd5yNG05Ffu4XLeiSvOoI0x7cPpb94LS72yjIf2hnzn6YOx
         2eAXCFGilolW4vTWkjq9c+4jJit9X65nKibSc=
X-Google-Smtp-Source: APXvYqxgW81Bh2gp7NfuMEuRgXEMzo82PKr8YV24UjJAd/l8I+5fzMkYsTUGjI8mWOY9506/uxTouQ==
X-Received: by 2002:a17:902:7c05:: with SMTP id x5mr3338168pll.321.1565099336115;
        Tue, 06 Aug 2019 06:48:56 -0700 (PDT)
Received: from localhost ([2620:15c:6:12:9c46:e0da:efbf:69cc])
        by smtp.gmail.com with ESMTPSA id a3sm22037629pje.3.2019.08.06.06.48.54
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 06 Aug 2019 06:48:55 -0700 (PDT)
Date: Tue, 6 Aug 2019 09:48:53 -0400
From: Joel Fernandes <joel@joelfernandes.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, Alexey Dobriyan <adobriyan@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Borislav Petkov <bp@alien8.de>, Brendan Gregg <bgregg@netflix.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Christian Hansen <chansen3@cisco.com>, dancol@google.com,
	fmayer@google.com, "H. Peter Anvin" <hpa@zytor.com>,
	Ingo Molnar <mingo@redhat.com>, Jonathan Corbet <corbet@lwn.net>,
	Kees Cook <keescook@chromium.org>, kernel-team@android.com,
	linux-api@vger.kernel.org, linux-doc@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
	Mike Rapoport <rppt@linux.ibm.com>, minchan@kernel.org,
	namhyung@google.com, paulmck@linux.ibm.com,
	Robin Murphy <robin.murphy@arm.com>, Roman Gushchin <guro@fb.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>, surenb@google.com,
	Thomas Gleixner <tglx@linutronix.de>, tkjos@google.com,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Vlastimil Babka <vbabka@suse.cz>, Will Deacon <will@kernel.org>
Subject: Re: [PATCH v4 4/5] page_idle: Drain all LRU pagevec before idle
 tracking
Message-ID: <20190806134853.GB15167@google.com>
References: <20190805170451.26009-1-joel@joelfernandes.org>
 <20190805170451.26009-4-joel@joelfernandes.org>
 <20190806084357.GK11812@dhcp22.suse.cz>
 <20190806104554.GB218260@google.com>
 <20190806105149.GT11812@dhcp22.suse.cz>
 <20190806111921.GB117316@google.com>
 <20190806114402.GX11812@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190806114402.GX11812@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 06, 2019 at 01:44:02PM +0200, Michal Hocko wrote:
[snip]
> > > > This operation even if expensive is only done once during the access of the
> > > > page_idle file. Did you have a better fix in mind?
> > > 
> > > Can we set the idle bit also for non-lru pages as long as they are
> > > reachable via pte?
> > 
> > Not at the moment with the current page idle tracking code. PageLRU(page)
> > flag is checked in page_idle_get_page().
> 
> yes, I am aware of the current code. I strongly suspect that the PageLRU
> check was there to not mark arbitrary page looked up by pfn with the
> idle bit because that would be unexpected. But I might be easily wrong
> here.

Yes, quite possible.

> > Even if we could set it for non-LRU, the idle bit (page flag) would not be
> > cleared if page is not on LRU because page-reclaim code (page_referenced() I
> > believe) would not clear it.
> 
> Yes, it is either reclaim when checking references as you say but also
> mark_page_accessed. I believe the later might still have the page on the
> pcp LRU add cache. Maybe I am missing something something but it seems
> that there is nothing fundamentally requiring the user mapped page to be
> on the LRU list when seting the idle bit.
> 
> That being said, your big hammer approach will work more reliable but if
> you do not feel like changing the underlying PageLRU assumption then
> document that draining should be removed longterm.

Yes, at the moment I am in preference of keeping the underlying assumption
same. I am Ok with adding of a comment on the drain call that it is to be
removed longterm.

thanks,

 - Joel


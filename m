Return-Path: <SRS0=bR/Z=QL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 648BBC282CC
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 20:42:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0A67F2073D
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 20:42:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0A67F2073D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 508D98E005C; Mon,  4 Feb 2019 15:42:25 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4B8E08E001C; Mon,  4 Feb 2019 15:42:25 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3CEF78E005C; Mon,  4 Feb 2019 15:42:25 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id EC2FE8E001C
	for <linux-mm@kvack.org>; Mon,  4 Feb 2019 15:42:24 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id o9so660634pgv.19
        for <linux-mm@kvack.org>; Mon, 04 Feb 2019 12:42:24 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=FzmzpXuu8/fCHSd4jyfgEbXlD9wvm1SVDNvI6+YSdb4=;
        b=B1NzwyrshsG3jUD6TP8rs4U7EbwcGbQhXdH99IuE/72M8skGZvtvjJyeI+fVcsKsym
         cnRRqVmV+xhf20DU+0KOPA7YOuDKimXM9NTegNrIt7dhWCph+JMNiBqqVJoLXxjx+wEQ
         vEGJabfXsvdZkYGnTs+6HTsXGAO89IjI7+siFVojjuaLl2WFZJI2uJeb3BdXZ7/Rc5Bo
         b1JMWHgntaJSfC8m6DytKicw+cv5BeJkAcTmLqHrJByU7VeZnuZfsQiwayzgvB/GwOvC
         r2Fw2zqjlyKNBFmlfmyfYPmYunFm4OgRRT1VhOA8+uQdhngd7HA8DSovch9MivOVmKq0
         iXdw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuaSr5jeOxeiSP2NUa/Co+EA8/hYCVkXG7Y5Ateqz7AYlYHvn2aw
	as0BhoXJALgG+A0awHisY6C0jV5YtlHExbAAqbE7/G9o64icDzohfgp3m1hTZsKrY+xnyCI6NcI
	kxyy3AnIimXz0PDasz+Oe2R7RmBg8ONlNOBU9CrBCzV/z9C0lBWAMdbNYCbaNwdl+wg==
X-Received: by 2002:a17:902:8687:: with SMTP id g7mr1332302plo.96.1549312944565;
        Mon, 04 Feb 2019 12:42:24 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYXZ2i8KBWDF1cIT2gfRGSQdpmzgq1Uu0mQpwQlfTAutR/JxheTKVJgDy51t39WIlfihpkn
X-Received: by 2002:a17:902:8687:: with SMTP id g7mr1332246plo.96.1549312943770;
        Mon, 04 Feb 2019 12:42:23 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549312943; cv=none;
        d=google.com; s=arc-20160816;
        b=jSBCV91MIANOU8Cu6NwbsCahDL+Y/25DpR/tLPfC3ST6iOGnegamLDiDZv4WZhjt1y
         4jtzIK9ghCELlfH3QLLgs3tYElSguXHorSxHbmzM5NJeOktamhPcPXINhVvkciPqgG9K
         Jxs4RbNFusYlhYsgb9VXUqp7NLHqnfO1wgHONz5+UWlfi3NwnAZQu7Zqgcb+brzE+hHa
         71uf+pMNziy7UO/310+yI1GUlVIV8R8HhRhQNmJa+WgROkjCSSv7uP1CbSBX5pfOGdH/
         PFJVhKUcbKHrB6GOuou6lTNVNaTTGcthBJ7xMlXtM6mRsp7mdw7WF6eBlSJsdIT68twr
         hpCQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=FzmzpXuu8/fCHSd4jyfgEbXlD9wvm1SVDNvI6+YSdb4=;
        b=xLmvU/X2+eKdZWF4mDW+8re//nN2Vn+pNTYbb+3eiAcJAwP1CA7pwaPP/rSx9TgbBP
         jBNTU/4W2hEEN9+dKtgjtQsRSoiykCxpvNROlgIneNZEmjsWqPydaxU6I7pGla2rBhQm
         iEYggQmcy46noVUA1jaHS+aFn+eKKK4fXWNZ/4Krm5Ed++BKLz+iyl52SkAmg7aOru0N
         loEDlYY704gEbUg8qy2ArhH0kSYuMLDLyZPrO1iDHfUJXn6NB+5MNqNJVmrdBT/D3jG4
         FEplOU69YOVYOL9dN7cXF7SmzKPWcqP7MzZRuIaXbdRpnZP1+S0O6MXp9GxQ0m4WsmU9
         G3Xw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id p4si1044182pli.432.2019.02.04.12.42.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Feb 2019 12:42:23 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.88 as permitted sender) client-ip=192.55.52.88;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by fmsmga101.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 04 Feb 2019 12:42:22 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,560,1539673200"; 
   d="scan'208";a="115242169"
Received: from ahduyck-desk1.jf.intel.com ([10.7.198.76])
  by orsmga008.jf.intel.com with ESMTP; 04 Feb 2019 12:42:22 -0800
Message-ID: <d921273395b236bbc07bd7abd0359108b819448c.camel@linux.intel.com>
Subject: Re: [RFC PATCH 3/4] kvm: Add guest side support for free memory
 hints
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
To: Dave Hansen <dave.hansen@intel.com>, Alexander Duyck
 <alexander.duyck@gmail.com>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org,  kvm@vger.kernel.org
Cc: rkrcmar@redhat.com, x86@kernel.org, mingo@redhat.com, bp@alien8.de, 
 hpa@zytor.com, pbonzini@redhat.com, tglx@linutronix.de,
 akpm@linux-foundation.org
Date: Mon, 04 Feb 2019 12:42:22 -0800
In-Reply-To: <24277842-c920-4a12-57d1-2ebcdf3c1534@intel.com>
References: <20190204181118.12095.38300.stgit@localhost.localdomain>
	 <20190204181552.12095.46287.stgit@localhost.localdomain>
	 <24277842-c920-4a12-57d1-2ebcdf3c1534@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.28.5 (3.28.5-2.fc28) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2019-02-04 at 11:44 -0800, Dave Hansen wrote:
> On 2/4/19 10:15 AM, Alexander Duyck wrote:
> > +#ifdef CONFIG_KVM_GUEST
> > +#include <linux/jump_label.h>
> > +extern struct static_key_false pv_free_page_hint_enabled;
> > +
> > +#define HAVE_ARCH_FREE_PAGE
> > +void __arch_free_page(struct page *page, unsigned int order);
> > +static inline void arch_free_page(struct page *page, unsigned int order)
> > +{
> > +	if (static_branch_unlikely(&pv_free_page_hint_enabled))
> > +		__arch_free_page(page, order);
> > +}
> > +#endif
> 
> So, this ends up with at least a call, a branch and a ret added to the
> order-0 paths, including freeing pages to the per-cpu-pageset lists.
> That seems worrisome.
> 
> What performance testing has been performed to look into the overhead
> added to those paths?

So far I haven't done much in the way of actual performance testing.
Most of my tests have been focused on "is this doing what I think it is
supposed to be doing".

I have been debating if I want to just move the order checks to include
them in the inline functions. In that case we would end up essentially
just jumping over the call code.


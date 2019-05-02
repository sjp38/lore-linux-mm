Return-Path: <SRS0=Mdb/=TC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 624E9C43219
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 21:25:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1D8C62081C
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 21:25:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="AgY5AF+e"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1D8C62081C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AEE566B000A; Thu,  2 May 2019 17:25:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A9E966B000C; Thu,  2 May 2019 17:25:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 967766B000D; Thu,  2 May 2019 17:25:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 498A76B000A
	for <linux-mm@kvack.org>; Thu,  2 May 2019 17:25:42 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id z5so1725042edz.3
        for <linux-mm@kvack.org>; Thu, 02 May 2019 14:25:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=oqcKatM0uGeQ3Db2t4iHmyuMiU+/ILY+eE3Km3ykIKY=;
        b=hTYBPt0WQVX4FML8pDdF/9sBLeDNTwB4+MZhz3+RRhgzEKWp32UnIRJFbvL+ubnpmX
         0XujNAngrQG1orOSUKR7elb8KC0nTSQDys8fCwEHdZeM8XmXdv2Ig+gtTRG+WIZXKqJA
         LOfKzPm37Na8EO8a/zE7wJixQTrHp+BRxufl83KUyWyORAE7A0M2owVxkL7/sX6LKCKV
         Xht/4SlEmQLeWIiBGfgDCKaMKgXSiMbDhKOWt9tkCzKtNZodnX9Pw7lZ9/ZolFCEvlT/
         YQaRophP4LGjo9EskamyY8ZL0wiMkll+S0XxyRuNCr3PqPQAd6gjug5IlZrywA1VFahU
         HNbw==
X-Gm-Message-State: APjAAAVA7Jh8jb2Zs4iV6hpprp9axgFObPlzYKeJ1eIWHGX0d8SQhwry
	ClMFO/jj8E2rWemg26nLIOyW5s6lasvmV4wdPKZffexyBtKJqeyXFm+ibMVlxsH9fZS3zLHOeIX
	ZM4gl21k0URcc/xXvp5ToNARNI+DaLmzerDxHd7VgjU0k26QHaBJZTe0zoEG9sqM3CA==
X-Received: by 2002:a50:8684:: with SMTP id r4mr4225948eda.98.1556832341805;
        Thu, 02 May 2019 14:25:41 -0700 (PDT)
X-Received: by 2002:a50:8684:: with SMTP id r4mr4225903eda.98.1556832340991;
        Thu, 02 May 2019 14:25:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556832340; cv=none;
        d=google.com; s=arc-20160816;
        b=lwT/n2xnffKqu+jhoQnRY1OcnXFoKeHnlBfKNz2tP+9uwi0ERNAZp+BodaXw0rmky7
         JbpgpDu92AhptAFQw2uD0rMeqwoHqjzNaFUIS6dYRs+vv15fr5sYaZvjL3QzQRrJOktK
         14eo0Ga3nlnh9jYAPdFFBjqPj3AstjAxqVJ6ztCnyXWGr31LFOJxLy19bAIFwP8glmdh
         NbREot/PyDss6di+7gm3AVBcq0V4398CYYSM1eV9SWBhmvgPnwdrefTTuW1+gg0DOgKn
         JMmKuy3+X4f7qHhaAQvlAlJuX8yYICIHlFL31YzmnYyvsp1sGCHpQgHLrhosHMB2Gxlh
         jyqQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=oqcKatM0uGeQ3Db2t4iHmyuMiU+/ILY+eE3Km3ykIKY=;
        b=IM8buG495u+kwTYzq3BxfFulIL7YK3tnJWOpLDPeNVHvZs+oKT8G7aeiL1TRuNjMUf
         mQL0fnX8pvcbiIcTbILzkOgdIKFNeFqsFUaAvPpcTryx74QBkAf8snrKnyY8hodSpjaR
         53EK8Siy3xZ6CzHdJMBVvIjvbZIbBn1jCc+5NZwxSp946mjrrsXttDRZhlFsVQYhPYYP
         mSFNgq+iH2E5ZTESn+6A2eSL1ZrllFFLL2pcuwrUPcHtG5a1Sbmint3xhIT9RnRerogF
         dQEPlHYTIVptoSkMlhMTqvTNPNfqFRd3ihJyCHs8HjBtE5MjIdFr6TG1FxqR0NJZ3A1K
         meow==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=AgY5AF+e;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p26sor143194edy.1.2019.05.02.14.25.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 02 May 2019 14:25:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=AgY5AF+e;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=oqcKatM0uGeQ3Db2t4iHmyuMiU+/ILY+eE3Km3ykIKY=;
        b=AgY5AF+e2le1uHZ3YDirUDNp1TICE3KTNFAqpOvtdLkS6yP1eLKWPoHzGo8y9rmtXP
         W5zYcv98aBbZRyN6WhuuD5cQ5xqFsd7QAANcsN+hKVdl2kYcFm3t/jFqXFnaBJcd2GsR
         XSH+++y4C9Te7uKfEGbSKMFWD0QzFyal9FhNZU8FNJcQpwO1Sh0atef843W+/TVcR2ur
         Xk+F4nnTDSgAxLXtTCOJZ5/rYr63SJP5+lF0QpnikjbrXj+LKIy42y1uDsDvKIN248Ih
         lEBjsaxOweTFgodUin00Y7YTcqWXk0wvSLTestHkzf9wEtJJoQGFzv9jnuBtRgOEJwFy
         o2zw==
X-Google-Smtp-Source: APXvYqw1VQMw7Xf/epk8qLnpcgvdR+kuprbmNMpiiIscKSKCrluznkQGvwnw3n2TtUh1xmbwidclePAglNL4CTqh4Pg=
X-Received: by 2002:a50:fb19:: with SMTP id d25mr4206716edq.61.1556832340698;
 Thu, 02 May 2019 14:25:40 -0700 (PDT)
MIME-Version: 1.0
References: <155552633539.2015392.2477781120122237934.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155552637717.2015392.6818206043460116960.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <155552637717.2015392.6818206043460116960.stgit@dwillia2-desk3.amr.corp.intel.com>
From: Pavel Tatashin <pasha.tatashin@soleen.com>
Date: Thu, 2 May 2019 17:25:29 -0400
Message-ID: <CA+CK2bBY2KgLGsXJDhsZe3QV-871O07Yx+fvMwU2_zNNn+zjzA@mail.gmail.com>
Subject: Re: [PATCH v6 08/12] mm/sparsemem: Prepare for sub-section ranges
To: Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, 
	Vlastimil Babka <vbabka@suse.cz>, Logan Gunthorpe <logang@deltatee.com>, linux-mm <linux-mm@kvack.org>, 
	linux-nvdimm <linux-nvdimm@lists.01.org>, LKML <linux-kernel@vger.kernel.org>, 
	David Hildenbrand <david@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 17, 2019 at 2:53 PM Dan Williams <dan.j.williams@intel.com> wrote:
>
> Prepare the memory hot-{add,remove} paths for handling sub-section
> ranges by plumbing the starting page frame and number of pages being
> handled through arch_{add,remove}_memory() to
> sparse_{add,remove}_one_section().
>
> This is simply plumbing, small cleanups, and some identifier renames. No
> intended functional changes.
>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Logan Gunthorpe <logang@deltatee.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>

Reviewed-by: Pavel Tatashin <pasha.tatashin@soleen.com>


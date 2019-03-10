Return-Path: <SRS0=tu4S=RN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 656F7C10F03
	for <linux-mm@archiver.kernel.org>; Sun, 10 Mar 2019 21:03:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 02D1820848
	for <linux-mm@archiver.kernel.org>; Sun, 10 Mar 2019 21:03:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="w0J12NO7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 02D1820848
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linuxfoundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 56FBA8E0008; Sun, 10 Mar 2019 17:03:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 51EA28E0002; Sun, 10 Mar 2019 17:03:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 40ED38E0008; Sun, 10 Mar 2019 17:03:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 015258E0002
	for <linux-mm@kvack.org>; Sun, 10 Mar 2019 17:03:46 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id u8so3805216pfm.6
        for <linux-mm@kvack.org>; Sun, 10 Mar 2019 14:03:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=oScQXXzn/QCgZCgzcut/WM/f5LNzl/KH38WofbO0suI=;
        b=t5VxXTnbDeoOFqtYg/vpmaAQjhFNkNrSU8FJjlHSADH6lTIljUq37uOURmcXA5IIkY
         2bhm1ttto4cdYWRMomOqNvbeRJGyvbY+O2wvrWO7N7z4E3F4D7esBO3WyDG0wMHmz9mS
         RJPWlLUd65DODmVs42V0NfhV98tUu0CLzOsMcjrm/fQaLRUsZ7udy0578I2gpSBdzGN5
         WIy+B6+Ndr/LDoHNWmPNQX+uwz3Zclekywg78kExORt/yKitbIPgVG2FDFH+s5HATJui
         EBpw7TZA514ZGdlhfh9vfmHYBsY3XN9CJdvMMHDY7cMws8bXqDWdyxpU2ruB3pkvMgkD
         iElA==
X-Gm-Message-State: APjAAAUWTPf3WxhplLmwylRiX+nNs18t4LnhRrbCjs4ejI/dGxtDbZ6S
	k+RFCTkuxGrjG7fozrsBJ+suoLnsaC9WEZsvKT9bUAp52NBANM6zZPsbAhmronzartqkoJg8dQ6
	ZByIXNfJzJupPo34USjFZ3E/8VhntqNTb3PtYRApfUGqizditfv1/wf65cgZfLAgymg==
X-Received: by 2002:a17:902:7881:: with SMTP id q1mr29568996pll.301.1552251825426;
        Sun, 10 Mar 2019 14:03:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy4yl6lMVlGKx9/IiaP3AqAy7H/G5ycZqjpvE7t0dXgNG2EG83M2QX3ZV84LgCa7qBBidzc
X-Received: by 2002:a17:902:7881:: with SMTP id q1mr29568929pll.301.1552251824499;
        Sun, 10 Mar 2019 14:03:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552251824; cv=none;
        d=google.com; s=arc-20160816;
        b=IbKMEjqngUkK1o9Xnz8l5LM5l2oxV4bDIYtXrEXNpCrWlDUDapeSo1Ljrwol5aabGI
         A948nCLV71zN636pNFbZEpxge4KqDsAQMtV6UoGiLd/MJnlQeayI7rilCtFQwLuAAq8a
         0bo6eiwfcdo6Rj4pgF17X67FP6gYAhAmtC0dwIzHSnB86tt5hmr+t/9of9yGtRlHgPVv
         kUE4rmAiCO++HJpHxu585SD4LGDSsFN5PNy0LKMA1JeH19HbXRBssRGM/XRxnC3BE7fQ
         TNyy2RQ5spoV/R0NmrTLNNDWL+56EKDcfGU5Lts23GctXTE2rxi/av17GHaDdzT4iZy9
         HBGw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=oScQXXzn/QCgZCgzcut/WM/f5LNzl/KH38WofbO0suI=;
        b=D9ueHq3Ec517B6jTYNzxmfLKUERV/s3nN7cNGJ8hgTkCHfrjU+H60VNjVQqSJbIMgv
         ZWWNwdqdyl6Jw2DM8NyDvDIx6NgLdYkiae+069WiWgR68xTbE6uG21BAP82EyrU4dwJO
         TGPq1jfEgQAyr6gH/qDSg5jt/kh43sQUTjQ3+yLDCbrc9XtC24H2IiORRjBEFWFgAOja
         JJeAN0UuF77WIIMrA6ByCKjYLFiS2E5glhAzGDS87RwPdIHMJM10BT2ALb6eudgRLQtf
         cY5M5TJ5VSpKOI4n/7EC8wp3eNBLb2KxXmu68z6JPnQpwxgMhGWBx0KLB46D8wfA3Xfg
         ulyw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=w0J12NO7;
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id h12si3518434pgl.277.2019.03.10.14.03.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 10 Mar 2019 14:03:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=w0J12NO7;
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from localhost (unknown [104.153.224.167])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id EB108206BA;
	Sun, 10 Mar 2019 21:03:42 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1552251823;
	bh=q0PUVwOut6IVrnZMVAnvSVuPugbFv1l0jGrQRBXv2MY=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=w0J12NO7pJBumbfQjHBiN3c7+guKb1CsNQER8w6nokTEfrC3lHAyuqSc6KiDMXPSO
	 vxgIkAy0avn0LAFTGqfqezpRqDKfvPbTGUIe4UZIlB2GG6GugnIxTWg/gs+LhAxkfm
	 0jEf+AO0gd6VPsDh/wC81p9mKudaiP+LJ8KgydGk=
Date: Sun, 10 Mar 2019 22:03:35 +0100
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: Sultan Alsawaf <sultan@kerneltoast.com>
Cc: Arve =?iso-8859-1?B?SGr4bm5lduVn?= <arve@android.com>,
	Todd Kjos <tkjos@android.com>, Martijn Coenen <maco@android.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Christian Brauner <christian@brauner.io>,
	Ingo Molnar <mingo@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org,
	devel@driverdev.osuosl.org, linux-mm@kvack.org,
	Suren Baghdasaryan <surenb@google.com>,
	Tim Murray <timmurray@google.com>
Subject: Re: [RFC] simple_lmk: Introduce Simple Low Memory Killer for Android
Message-ID: <20190310210335.GA5504@kroah.com>
References: <20190310203403.27915-1-sultan@kerneltoast.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190310203403.27915-1-sultan@kerneltoast.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Mar 10, 2019 at 01:34:03PM -0700, Sultan Alsawaf wrote:
> From: Sultan Alsawaf <sultan@kerneltoast.com>
> 
> This is a complete low memory killer solution for Android that is small
> and simple. It kills the largest, least-important processes it can find
> whenever a page allocation has completely failed (right after direct
> reclaim). Processes are killed according to the priorities that Android
> gives them, so that the least important processes are always killed
> first. Killing larger processes is preferred in order to free the most
> memory possible in one go.
> 
> Simple LMK is integrated deeply into the page allocator in order to
> catch exactly when a page allocation fails and exactly when a page is
> freed. Failed page allocations that have invoked Simple LMK are placed
> on a queue and wait for Simple LMK to satisfy them. When a page is about
> to be freed, the failed page allocations are given priority over normal
> page allocations by Simple LMK to see if they can immediately use the
> freed page.
> 
> Additionally, processes are continuously killed by failed small-order
> page allocations until they are satisfied.
> 
> Signed-off-by: Sultan Alsawaf <sultan@kerneltoast.com>

Wait, why?  We just removed the in-kernel android memory killer, we
don't want to add another one back again, right?  Android Go devices
work just fine with the userspace memory killer code, and those are "low
memory" by design.

Why do we need kernel code here at all?

thanks,

greg k-h


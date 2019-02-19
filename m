Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1C754C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 03:21:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C4E152147C
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 03:21:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ozlabs.org header.i=@ozlabs.org header.b="Gu8tRS7r"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C4E152147C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ozlabs.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 625978E0003; Mon, 18 Feb 2019 22:21:47 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5D53C8E0002; Mon, 18 Feb 2019 22:21:47 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4E9EF8E0003; Mon, 18 Feb 2019 22:21:47 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1C7CD8E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 22:21:47 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id h70so15209853pfd.11
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 19:21:47 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=rw3Hl9r5ZuPciGC8lJMpl2mvDvpsTvOb1Q1/wdK/J0w=;
        b=kNg7N3zjf3qKE3F6JN6mDy7KXKx0riTAsPhLqS85KOP5j6YOFzH6Dpbh+AIkozp0L3
         N+3MU0+QZHFKY9Jr6kdcIVsAsXeUsMdLLciIM9C67RYXpZvjhaQWHgvZ9RRgaoWNw4ln
         XBMB+nHbKdIZ5VvfRX9K9FBi4rziS29TH3YdaduLeSg20/Te6SHTF8HpPgByEJI9GeGY
         /VG5WLQjUExY3/EDKkPAxbgPYWhIjmiC7Nb4UICivlhYduavSCFEh2S/PQBJuNyqLGVp
         gDanIOeEeJTV3VLEWM1pg784vKi0y0wCkhHe7i91B6Mz9y7HGASOLVyRmD4VFb9UKRdW
         GDKQ==
X-Gm-Message-State: AHQUAuaeRPocQoQpE44MJrpXGRj44xGSFLf3iwlU0+HvgH2Dh3Dst6tS
	mgxS6ZsQOpOkFBXVAvXelHGn7HXO3Y9xLwEPQJUsgedoNv6aCOkd0YiUjsx/3YUjSAVVkKtq2Ce
	WYUVZ9vzqohxC9KuWdgOvuHbT3osgi3GJzPGq2pGeDeNPrvkJ6TVePraFu6rc0L8s3Q==
X-Received: by 2002:aa7:8508:: with SMTP id v8mr27278760pfn.14.1550546506699;
        Mon, 18 Feb 2019 19:21:46 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYvFh1tjiirv3Wx3SFt/ZWUOipxPXHPyHPv6IHFOA2n+yDRsOWye0MwhEPE/iaxklDPTACQ
X-Received: by 2002:aa7:8508:: with SMTP id v8mr27278708pfn.14.1550546505764;
        Mon, 18 Feb 2019 19:21:45 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550546505; cv=none;
        d=google.com; s=arc-20160816;
        b=z8vVOYt/o5+RdPcY9pfjHtOo4MyT7tOPp5U+Q79+G/GwVY0d4z9wjmjNB3bsY8Tosa
         eOiH79koVgQJZivLLHyuH1n0/oHdPzHgeJbVwZOzHBT9t9F9dJuZ5/zikk3e+T2/mbbJ
         Lu+mbwjXk3EhDy+FOGOw6UjgnZytX6e3GvHb4aLPN3FBbcxOuXQfxxO00TfK6UBNrYou
         AtliQdik4J2Cdmk/75xV3JfN58oSgVHjgOgLu67NqdLI9QGH2ADubPVnzu6aVJPTRAqZ
         asJVs/CNrUZeHka42WrJ7hVm+qsOKqF3gwthl8pBaSRBbKR37b2OYAO4GpwLyhH8N89x
         FiSg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=rw3Hl9r5ZuPciGC8lJMpl2mvDvpsTvOb1Q1/wdK/J0w=;
        b=YCjOM5E3RPOoxq8ci87rDXeJfdTqW4mqo6pvOSV/bjP1xFyj3w0i0dWeSVL0jANWFG
         M21zm/zVQYfkiku1tO8UIn6URfzmCsfAotAF/YJmluvf8ISX7TD0nDXeV0OvqGRpQnKP
         x5RRswM12xPypPEGsRljTLsq5bJBLkA4f+YZ23ogJjdgvkgZk8Upwrbm2GF6X41G+qrn
         QOKQjZ760LfAwKYPoOdEu04YMuWk3RxFFdpUKUmIwRTfu2WHZukdv69FplQhn7GE26C+
         yVGV2VUNrHwwLDHeiU3BpxAPsg1EkN4Wba5GSLbgu2wm4UbJZLkzl/K5hLSQTWFMErl9
         Sbjg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ozlabs.org header.s=201707 header.b=Gu8tRS7r;
       spf=pass (google.com: domain of paulus@ozlabs.org designates 203.11.71.1 as permitted sender) smtp.mailfrom=paulus@ozlabs.org
Received: from ozlabs.org (ozlabs.org. [203.11.71.1])
        by mx.google.com with ESMTPS id q2si13944205pgv.124.2019.02.18.19.21.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 18 Feb 2019 19:21:45 -0800 (PST)
Received-SPF: pass (google.com: domain of paulus@ozlabs.org designates 203.11.71.1 as permitted sender) client-ip=203.11.71.1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ozlabs.org header.s=201707 header.b=Gu8tRS7r;
       spf=pass (google.com: domain of paulus@ozlabs.org designates 203.11.71.1 as permitted sender) smtp.mailfrom=paulus@ozlabs.org
Received: by ozlabs.org (Postfix, from userid 1003)
	id 443Qxz4drrz9sDL; Tue, 19 Feb 2019 14:21:43 +1100 (AEDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=ozlabs.org; s=201707;
	t=1550546503; bh=C4HLRcI4ypCgdGuAUaWYJlccB1gE29ZZS2GrzcNQN90=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=Gu8tRS7rJAFvgDvEDp81cn1xylOlkuDzmL4CtPcfDyOg2uMuaOcv4rZyEGZR7NyzL
	 958zm0atvwfeQgHGkWrR3/ZVcHfKSX6dNzw3dLCO6idaGwOy6D5imZS/SLY6uxEkjZ
	 OgXG+jWFgIJkqYg7CiNMvkEQRAk1S/+Q1ab59lOddnU3TjH4a1FfGZz4gyQhFZPk3y
	 6OPkQymMisT2ueB+CIvpVwk5SpZVu6y9op65eLo+Wx/R0cV5Xtz/ri6PpGH3ohBQvR
	 lpGL/drQryVYhBucwTTVlelN9e+fxP6uAUeOSUKTe7yc/nlYv/+WpKiUvWcrqL1Psm
	 Hyya9yfN3sz8w==
Date: Tue, 19 Feb 2019 14:21:40 +1100
From: Paul Mackerras <paulus@ozlabs.org>
To: Bharata B Rao <bharata@linux.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org, kvm-ppc@vger.kernel.org,
	linux-mm@kvack.org, paulus@au1.ibm.com, benh@linux.ibm.com,
	aneesh.kumar@linux.vnet.ibm.com, jglisse@redhat.com,
	linuxram@us.ibm.com, sukadev@linux.vnet.ibm.com
Subject: Re: [RFC PATCH v3 3/4] kvmppc: H_SVM_INIT_START and H_SVM_INIT_DONE
 hcalls
Message-ID: <20190219032140.GA5353@blackberry>
References: <20190130060726.29958-1-bharata@linux.ibm.com>
 <20190130060726.29958-4-bharata@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190130060726.29958-4-bharata@linux.ibm.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 30, 2019 at 11:37:25AM +0530, Bharata B Rao wrote:
> H_SVM_INIT_START: Initiate securing a VM
> H_SVM_INIT_DONE: Conclude securing a VM
> 
> During early guest init, these hcalls will be issued by UV.
> As part of these hcalls, [un]register memslots with UV.

That last sentence is a bit misleading as it implies that
H_SVM_INIT_DONE causes us to unregister the memslots with the UV,
which is not the case.  Shouldn't it be "As part of H_SVM_INIT_START,
register all existing memslots with the UV"?

Also, do we subsequently communicate changes in the memslots to the
UV?

Paul.


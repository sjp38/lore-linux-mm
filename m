Return-Path: <SRS0=SdaL=XB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1C6DFC43331
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 19:06:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D75A220838
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 19:06:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="FQTP/Tmg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D75A220838
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 83E296B000A; Fri,  6 Sep 2019 15:06:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7EE456B000C; Fri,  6 Sep 2019 15:06:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6DCE66B000D; Fri,  6 Sep 2019 15:06:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0046.hostedemail.com [216.40.44.46])
	by kanga.kvack.org (Postfix) with ESMTP id 46E8E6B000A
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 15:06:49 -0400 (EDT)
Received: from smtpin05.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id D2960824CA11
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 19:06:48 +0000 (UTC)
X-FDA: 75905427696.05.pail47_759f48100c71d
X-HE-Tag: pail47_759f48100c71d
X-Filterd-Recvd-Size: 3915
Received: from mail-ed1-f68.google.com (mail-ed1-f68.google.com [209.85.208.68])
	by imf15.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 19:06:48 +0000 (UTC)
Received: by mail-ed1-f68.google.com with SMTP id t50so7282078edd.2
        for <linux-mm@kvack.org>; Fri, 06 Sep 2019 12:06:48 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Y2omJ3/dD4U+vCtoy8H75XszRI5XH+eQMkgkdDPlArY=;
        b=FQTP/TmgHTgyC+PBU5SEyiseIy1zvJC97N+VhKG2dCvL9vAhP80LEhoKJOvzIi6bLQ
         BgVBFgf58SS8R6ppJO3IlLnneB06um+xoINkqVeAcoexAD7EM8Pa8+VTq2HkDgPCOmt1
         TOn3ZhGsy7GLjFuJ1Jsk7gydcJxrPs9xEq3rZGr9mprwu/oe6WREKg8EsucNQZWw2j6w
         J7ifMbBwHA1GZOQh8cnKXT8qN31F/vuBtp4u7YqNI+J47VPkt/zp22gNmPCRdoGMqBlZ
         nVh7RyWgx3VRI12mKbkkekJb4SMfWKAg2SUtXlgb9KFbdoDmStmdx61Q+ALcL6DiU6Eb
         OcSw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=Y2omJ3/dD4U+vCtoy8H75XszRI5XH+eQMkgkdDPlArY=;
        b=lChcjoOz9QZbCzrCE4dl4G60/wLQzi0xht4GQLD6vmU/7Ploa8+V3R/rmSQTKZXsHW
         nO1j9IyigdOC7qDyOh1ue1sA/bI1Z+608xP0DMqEohmdQSoEcBLFYCeao/yDKy6A3s9/
         MgTw/d/+LAoT7QA9T/Tci/UMAClD5oyYw6dcm5pkqCQSDhMNMKLSRlj9KrOhHm+niQ1Z
         WqM7NcJl2Eadbmv1q4QJTFKKkwdy3Nj2fGbQEY5I4H/FOE5Nyns2hDN2+RPgf/TQpmfE
         TR+PRC+9yyQxk/dyoJkfVtB7WX/CT4YQt8RHlGPU/lO9YwD2+Ql/l6YhDv2814y+/PtI
         nDFw==
X-Gm-Message-State: APjAAAWLVp7uMV5eLYqEN+tHNQSYNcH5VqTSEl0ahm5LNsjfombbN4b8
	iWXf/UNY0NIVuOXkHRx/OZ0ejv5WxZO8op++/DcXUw==
X-Google-Smtp-Source: APXvYqxUyzboKtZynQf94VQal3O7BvvXwmvhzJw991UoDJCeN6nT1tLn0eiUP2pwGueZpl557B6qG/MIy5a1dR+RLhA=
X-Received: by 2002:a50:9ea1:: with SMTP id a30mr11569826edf.304.1567796807172;
 Fri, 06 Sep 2019 12:06:47 -0700 (PDT)
MIME-Version: 1.0
References: <20190821183204.23576-1-pasha.tatashin@soleen.com>
 <20190821183204.23576-13-pasha.tatashin@soleen.com> <d4a5bb7b-21c0-9f39-ad96-3fa43684c6c6@arm.com>
In-Reply-To: <d4a5bb7b-21c0-9f39-ad96-3fa43684c6c6@arm.com>
From: Pavel Tatashin <pasha.tatashin@soleen.com>
Date: Fri, 6 Sep 2019 15:06:36 -0400
Message-ID: <CA+CK2bDxK5DHARkAUxzodhMDqokqEy3Y12F-bgHPF9g9K496hA@mail.gmail.com>
Subject: Re: [PATCH v3 12/17] arm64, trans_pgd: complete generalization of trans_pgds
To: James Morse <james.morse@arm.com>
Cc: James Morris <jmorris@namei.org>, Sasha Levin <sashal@kernel.org>, 
	"Eric W. Biederman" <ebiederm@xmission.com>, kexec mailing list <kexec@lists.infradead.org>, 
	LKML <linux-kernel@vger.kernel.org>, Jonathan Corbet <corbet@lwn.net>, 
	Catalin Marinas <catalin.marinas@arm.com>, will@kernel.org, 
	Linux ARM <linux-arm-kernel@lists.infradead.org>, Marc Zyngier <marc.zyngier@arm.com>, 
	Vladimir Murzin <vladimir.murzin@arm.com>, Matthias Brugger <matthias.bgg@gmail.com>, 
	Bhupesh Sharma <bhsharma@redhat.com>, linux-mm <linux-mm@kvack.org>, 
	Mark Rutland <mark.rutland@arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Sep 6, 2019 at 11:23 AM James Morse <james.morse@arm.com> wrote:
>
> Hi Pavel,
>
> On 21/08/2019 19:31, Pavel Tatashin wrote:
> > Make the last private functions in page table copy path generlized for use
> > outside of hibernate.
> >
> > Switch to use the provided allocator, flags, and source page table. Also,
> > unify all copy function implementations to reduce the possibility of bugs.
>
> By changing it? No one has reported any problems. We're more likely to break it making
> unnecessary changes.
>
> Why is this necessary?

I tried to make it cleaner, but if you think the final version does
not make it better, I will keep the current versions.

Thank you,
Pasha


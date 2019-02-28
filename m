Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AF3ADC43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 19:39:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 71A23218B0
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 19:39:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 71A23218B0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EE9C08E0003; Thu, 28 Feb 2019 14:39:48 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E6F128E0001; Thu, 28 Feb 2019 14:39:48 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CEAEA8E0003; Thu, 28 Feb 2019 14:39:48 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 927558E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 14:39:48 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id s16so15807876plr.1
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 11:39:48 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=GOBGmfitmgfp2fZRXxCPM7NgqK7BmhpGJuQxWXI4opI=;
        b=K8GeCz5Z2MBjFNJKctWOLLXlESxBSh+k0lah2ZZwnxdXurq8GdGKp0Y+QXfRaqEtcP
         X8C6TGi4X46dN0P6D4UHgYpv+cLqIJ93TDqt85YBImolAg5kZwe/j7EVbIvNsh1KyVHA
         jcPBn3SaaVmJseC1Bc66bffMmGo3S57UhTnYuEsdjPatDONSGFb5EaWwC2g5Jn9l1Ies
         +tuPZNCDQUPsFj0dqW5FH0tGDT7+Z0ccIH/fE7DuJf4d123YSrpOR8h8H93RcpTuF13U
         +FKKbaRMLPxHDBQuWFWdapPTItwQ4UHIMuGHaTM3knp+O1Qqy/pXiYWYxdzJ7S2W+qKj
         6k2w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAVbBaTBsFc7LagBVPpHguH2xWKr9+yApNOF9Tb6QmCj3TNkofbN
	rrhBbMu5q9Wn9KmqlSJcwuB1/b/70AwxftFKXwfTt4f3m5zSIUemx/GjY6c8UTBYa5H5e5hqpzY
	3aPjiyQQezZnk71uoUEmgcCrwd+UJupf2UNGFAi9wyF5g7yrt34wG5gLJkA4yEBpHDA==
X-Received: by 2002:a17:902:2888:: with SMTP id f8mr1107736plb.244.1551382788265;
        Thu, 28 Feb 2019 11:39:48 -0800 (PST)
X-Google-Smtp-Source: APXvYqzwl9iGSRCPcEpKn8EAhCP7Dk8vwP8QFtOZWd6B2lMfUJksE0lkyvF6m/cCUMu6+RRDnk7p
X-Received: by 2002:a17:902:2888:: with SMTP id f8mr1107659plb.244.1551382787273;
        Thu, 28 Feb 2019 11:39:47 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551382787; cv=none;
        d=google.com; s=arc-20160816;
        b=M+y1jc2oxe54jOKoLkaAs1atkTDv8ctcszGUEqHwXIlaxJkDqqDY9l4P5oDrH+j9Zt
         8yBQ5HfdAAQkP94RGXhYAeDLDUZ5if7+5njYPhicdoKSXMZTVDBJRACjjdqzq1XmZiVd
         4GV9MzviCV4HzfEaPa79jrxeG7+b7Nb2qi3d7Da4rL1uBeikRIlY+OCAKEo2schC26U6
         WDhhqiFY4Ra9qAF3TcM7PWmGel0Vi5jpBepXGOZiFc5dwzUig/ST0ta4Iclb4wDHwncO
         Gd4SNwzOAR54rtod1q0bfJr1Dk62mL0ueXLaNYJOrivpJ6yG9rDSn8AyW0N+i3HgC1dn
         Y7YA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=GOBGmfitmgfp2fZRXxCPM7NgqK7BmhpGJuQxWXI4opI=;
        b=jV9jm9pdzDom0+Ni5KDNXTtbh96v7i1CNF83lFgGb7tHZSix/I0f50jomP35BT4iir
         U+mUVVOeTWLOurISLY3+ANniC91ayJ+3wSfYtptANv5qcO4NNCrXc6CVoJjRhOjnKliq
         aN1izu5B7RXRs6I8KR4crc3vJ50jNzN9agyCBUQwL0xVWcy2XDmUpUW/zGhwph+IJouR
         7gkTqaAnaiqeoZbroCfCJwDd42E6nBCb3urCWAL89iWYS9Y2p97NqemaZWUq+zIZ0oky
         aYLeVjF4hswUEaZVAZCcunf1UCVz8ucfQ9HIz96AtIGmBTHL3fPUrSgdyKzm844hny2e
         Xmdw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id s184si13208257pgs.279.2019.02.28.11.39.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Feb 2019 11:39:47 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 79B78ADD0;
	Thu, 28 Feb 2019 19:39:46 +0000 (UTC)
Date: Thu, 28 Feb 2019 11:39:45 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: npiggin@gmail.com, benh@kernel.crashing.org, paulus@samba.org,
 mpe@ellerman.id.au, x86@kernel.org, linuxppc-dev@lists.ozlabs.org,
 linux-mm@kvack.org
Subject: Re: [PATCH V5 0/5] NestMMU pte upgrade workaround for mprotect
Message-Id: <20190228113945.9d268b76bae26707e569681b@linux-foundation.org>
In-Reply-To: <87k1hltxoc.fsf@linux.ibm.com>
References: <20190116085035.29729-1-aneesh.kumar@linux.ibm.com>
	<20190226153733.2552bb48dd195ae3bd46c3ef@linux-foundation.org>
	<87k1hltxoc.fsf@linux.ibm.com>
X-Mailer: Sylpheed 3.6.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 27 Feb 2019 14:28:43 +0530 "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com> wrote:

> Andrew Morton <akpm@linux-foundation.org> writes:
> 
> > [patch 1/5]: unreviewed and has unaddressed comments from mpe.
> > [patch 2/5]: ditto
> > [patch 3/5]: ditto
> > [patch 4/5]: seems ready
> > [patch 5/5]: reviewed by mpe, but appears to need more work
> 
> That was mostly variable naming preferences. I like the christmas
> tree style not the inverted christmas tree. There is one detail about
> commit message, which indicate the change may be required by other
> architecture too. Was not sure whether that needed a commit message
> update.
> 
> I didn't send an updated series because after replying to most of them I
> didn't find a strong request to get the required changes in. If you want
> me update the series with this variable name ordering and commit message
> update I can send a new series today.
> 

OK, minor stuff.

The patches have been in -next for a month, which is good but we really
should get some review of the first three.


Return-Path: <SRS0=AeVH=PN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 18563C43444
	for <linux-mm@archiver.kernel.org>; Sat,  5 Jan 2019 19:46:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CE4CF22371
	for <linux-mm@archiver.kernel.org>; Sat,  5 Jan 2019 19:46:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="Omya8saF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CE4CF22371
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 78B238E0128; Sat,  5 Jan 2019 14:46:54 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 739608E00F9; Sat,  5 Jan 2019 14:46:54 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 651758E0128; Sat,  5 Jan 2019 14:46:54 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com [209.85.167.71])
	by kanga.kvack.org (Postfix) with ESMTP id E9E6C8E00F9
	for <linux-mm@kvack.org>; Sat,  5 Jan 2019 14:46:53 -0500 (EST)
Received: by mail-lf1-f71.google.com with SMTP id z10so3782617lfe.21
        for <linux-mm@kvack.org>; Sat, 05 Jan 2019 11:46:53 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=sfMKo7ATNMJUBNjbzn0K8OxXUEt33ltVZgJi38nELQs=;
        b=NwOKzH2Stk8M9US9fvQ00UNwUIKPagY4SQ+ROL946XWhS2fnVB2q1tFfSBM6HzTC4I
         wsQxe0VWE4gHGTCMeYoiQxLIaBVPTOgM0q0BNNyFb5NrG/1blcfCQ0+I8FW9YtY2L9J/
         tFlwq56zIXpA+L6FQr260PywhgPT4DgMt+an3v++FvqO5+p2YgkQ+YcoWWtsN4+IkVcl
         L3pgaIWOVHUohLOUv7hvE6ApiRSIpu8QX8W4R/ijcPm9imCTQeoN1X+pwaaWnUFbQ7Nc
         HdquGSXHteDYMfkekJaG01YgfHdDmEEodgSLI+/TIp37T8gT1wUKmxny2hNntMArQEAu
         mW0Q==
X-Gm-Message-State: AA+aEWYZzM++lsiqmSZWTTDHjrAa9hSAfFKPWiQEMWzYoX05qNJ2dcd0
	OuEohvvaAx0jheIds7/GHPD5uiAWdgw+o18HpyxP7AIQpDSlcTZBJ/iQvNbDgqOo7nLBJMZGBav
	z4wgc7S/UsCpAsdcOf0TVPfzfNz00k675cz/y5/k6DjFzu8zrlRQXIKmbzNHGmR/DG93/DPHoCO
	+t+DmenGRx6rb5LUBSMulx0ARNx2Un03r4zuT0VUrDRE6UE90jew5tlllrhbGHtBfiwyvmA1BWV
	KOtPcb+XPSUG14Z8U2s71v1wjQTcAnBQ3mkBEOKESUhs+prvlVtadN/L787+t7pxrBh+aPwOiH3
	tCarr+DRc8Vjvkw2xOpzfZIRDSRbC3uNQlSwIPnXCOR3EEf1so+zAkZ3a3Rac2gO+KyXKxCZ7QB
	R
X-Received: by 2002:a19:c4cc:: with SMTP id u195mr26749284lff.141.1546717612943;
        Sat, 05 Jan 2019 11:46:52 -0800 (PST)
X-Received: by 2002:a19:c4cc:: with SMTP id u195mr26749278lff.141.1546717612058;
        Sat, 05 Jan 2019 11:46:52 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546717612; cv=none;
        d=google.com; s=arc-20160816;
        b=0xt3HjChU2RlPlBHd1hAIamhnfb/dndV6sjBmzk4cot1IxpCzoAgwn/I18JdAQ4RTx
         AFbYGrLSHXBTR2LVn8EdtpKHEra1Q5oGI6ZYiBQC4NLnbJJCQKeXDJ22HA5UgXF7iwrr
         qq+a2OQpcuzErETsZosb9lc9/usG4jXC5uv44/DXUvN0mtpA8V++iV/pV9JqjHURK4n3
         qRW16lmM5cp70mFGXucStHA27flTav4euffgPG2IkQXS3gq/XUGIR14TeFJ4GUqjVd7p
         673OyJ6MJHIIV3Vq6/dZW33XjXIocB94dVM8h9VOeb+GeAef7gDyBuqVIUoGrs4WNolT
         X+jw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=sfMKo7ATNMJUBNjbzn0K8OxXUEt33ltVZgJi38nELQs=;
        b=JdTrzXLLaTU1/heTwdVx16HCVsUVQaxeeMuvRa1k/u3yrKdc2vTiTcqpevg6887l7j
         NMthLNYZygnRS8wrJvl/BcNSL3MdL4FSHjT1Bxp/ow2gNOdIiHZXoCBeEG3sUHOtv93R
         IXObwUXx3fwy/qtSWgrl94/u7g+zOlX65gySPWr7yPGqcBXazRehtwG5hnz3/A08uyVG
         +buzUY26DAVdyOVQ/gDgFSu3vmH/EijXWMQR0lBJTkwy02YDSqvKfZq8PJPz4QeSCwWg
         AlFvm57oDaN9ENDQiBIxy/kwDSJk/C8rzYkcMwkxM6MhnUHUFbmY0JOG7aZLKWTZ4QRv
         7QjA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=Omya8saF;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x82sor15219027lff.40.2019.01.05.11.46.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 05 Jan 2019 11:46:52 -0800 (PST)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=Omya8saF;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=sfMKo7ATNMJUBNjbzn0K8OxXUEt33ltVZgJi38nELQs=;
        b=Omya8saF/W27WjohuXlwpfrj4/+p7Bksv9DohJlsBfsrJA7OY/3Q3YPW0wVln7VJnM
         cs3qJ46WDfuFVB/SShwQNUY8X0wsqohZWk4LpS04v6uCOqfWBSB730CAc8u48gBSynwd
         qBDKTkyJmnFF3QumYh9Hw5nxCpVz1LDsRIMvs=
X-Google-Smtp-Source: ALg8bN71ZGPa6wUvmIgPlBm0oQbbTREOHa8ZRDkpomw8FCzfgssCY87djacp1Yk3xLqngDXpHgCb9Q==
X-Received: by 2002:a19:4cc3:: with SMTP id z186mr7324397lfa.37.1546717610923;
        Sat, 05 Jan 2019 11:46:50 -0800 (PST)
Received: from mail-lf1-f44.google.com (mail-lf1-f44.google.com. [209.85.167.44])
        by smtp.gmail.com with ESMTPSA id y23-v6sm13011951ljk.95.2019.01.05.11.46.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 05 Jan 2019 11:46:50 -0800 (PST)
Received: by mail-lf1-f44.google.com with SMTP id y14so8630522lfg.13
        for <linux-mm@kvack.org>; Sat, 05 Jan 2019 11:46:49 -0800 (PST)
X-Received: by 2002:a19:3fcf:: with SMTP id m198mr26611229lfa.106.1546717609589;
 Sat, 05 Jan 2019 11:46:49 -0800 (PST)
MIME-Version: 1.0
References: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm>
In-Reply-To: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 5 Jan 2019 11:46:33 -0800
X-Gmail-Original-Message-ID: <CAHk-=wicks2BEwm1BhdvEj_P3yawmvQuG3NOnjhdrUDEtTGizw@mail.gmail.com>
Message-ID:
 <CAHk-=wicks2BEwm1BhdvEj_P3yawmvQuG3NOnjhdrUDEtTGizw@mail.gmail.com>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
To: Jiri Kosina <jikos@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, 
	Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, 
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, linux-api@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190105194633._Y2tMRRkoSKmpfdkl-WYqhuIjVbST_Q_N74fl49HWbM@z>

On Sat, Jan 5, 2019 at 9:27 AM Jiri Kosina <jikos@kernel.org> wrote:
>
> From: Jiri Kosina <jkosina@suse.cz>
>
> There are possibilities [1] how mincore() could be used as a converyor of
> a sidechannel information about pagecache metadata.

Can we please just limit it to vma's that are either anonymous, or map
a file that the user actually owns?

Then the capability check could be for "override the file owner check"
instead, which makes tons of sense.

No new sysctl's for something like this, please.

             Linus


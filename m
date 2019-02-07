Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6F943C282D7
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 17:49:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 292BF21872
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 17:49:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 292BF21872
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=goodmis.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A48558E0058; Thu,  7 Feb 2019 12:49:55 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9F76A8E0002; Thu,  7 Feb 2019 12:49:55 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 911478E0058; Thu,  7 Feb 2019 12:49:55 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 51B238E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 12:49:55 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id m16so427426pgd.0
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 09:49:55 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Nxd5ClrrVIob/fH4TUFJ++cWeowkULSZzmi7Mew3MZw=;
        b=SuEKkQD3Cw5o/h/VtEazypCg+dz/bEB9pdbFug6vGvESVNKNJGLcOeYMxectQJnKz6
         uvs5S2nA5fCymkQXfhk/1ZRx5Q5C22lMXUWcVa6CegcWkaZ5c02AqNMZc/oyM8tOh7rD
         jkh+h3i4p5XmBOlJZwp1sBWiGQFyqtt8h+9t8x6w6hohOQV2pd9M8PZW5pqsjmSq+g/o
         +qlLhXMG9Fn/Vw8vIspEAPyiHlnNW8EjhQWjqlqyqgycgbFsJiLhsmAbySow68wjBX5C
         0p8HuW0iUMvZIcXK0xubo+Yx0LYV1UQR2yrCCIYs//31ZjC80fzCNW5X/31ava7bmcBl
         TDBw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of srs0=v3g0=qo=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=V3g0=QO=goodmis.org=rostedt@kernel.org"
X-Gm-Message-State: AHQUAub0BJLNxxpT0RePbyTeT91bPAmhnA/YHdXoJTM3OiROtDg0jPDS
	hDlXCDtTRXXkNFKagkG++cbFlKdrWaKnoMFsEIDbTKVTZfRzVrW7QysH16VK9US4MZhqh7Oq76l
	oNAvtybMtAb9c9uBWaM/OsdI90xfFyBufIicWCOUz3E8Pm+nZZBsjwSMZ8Vq4t/E=
X-Received: by 2002:a17:902:6b0c:: with SMTP id o12mr17909640plk.291.1549561795022;
        Thu, 07 Feb 2019 09:49:55 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaP5iEOjf68N2lQouJ1w79hdd8WGU5c9OfGrZOGBqnEzgeTbzRZl6gSmJljXIxQqvjI3Ob6
X-Received: by 2002:a17:902:6b0c:: with SMTP id o12mr17909589plk.291.1549561794420;
        Thu, 07 Feb 2019 09:49:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549561794; cv=none;
        d=google.com; s=arc-20160816;
        b=hhdv6tDqAaR+HhlW+6ZR3ucNczKYOylXm4Rz20qUKoxBE7dkh8oGqbEnxBywoEPb6Q
         k3i85YxkJpqNR1+X4fP9qNmtujRyJ2WfsQb3H10wcYmw1OLg8bsI+DufQL4PcM5/JnQS
         lhtNkMyMlNjw8LRzn4BYbOA7VTXBOmfUStcOjb+H+iYcFOT6yRtcSxfAwmzaImc0S43+
         d+Q580LY9syxWUBaBQijaHnYoVIsuFuM7/U3o+Vq+Q3pQClE8MdoiceWNJ1Ya81olE7v
         9kplJzgWMW/3bEb/ZKDI0/VxZqxue7fTkVvYd+ze/w5xOPoagsurPDWDHSHjW43qyhn+
         HcAQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=Nxd5ClrrVIob/fH4TUFJ++cWeowkULSZzmi7Mew3MZw=;
        b=VV0ieEJoLbD6MSLAu12GMfPkowocNZMOttUNvV0WaN5CddNqhH6Oh0a5BQgltj9KjX
         nEmp4u3od0OQvD5kS8o9eF99LTc7MO10oiVADF3B2X0NdwyzGkf+NWIzvth3loxhQJzZ
         s3+RMIk7jSyvX4ejPDnUodOqJJ50VDfTkpxdJkIynms4oVtUUfw5TifgIEnkjctHQw+y
         qfrCEj0xcTp3ip0aA4ccXcFt2jqFgVtJoBLP8FPJzsrvrjIF0ixc8V6H093K5b65J6Gq
         cHyI+J5BWbnfqHYzcnEm+hpz+znLSxhBE+eR/2Bl0BY1StfHeLhdOVFCdQeuXYJV4N2m
         Rm9g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of srs0=v3g0=qo=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=V3g0=QO=goodmis.org=rostedt@kernel.org"
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id c1si8616622pgt.247.2019.02.07.09.49.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Feb 2019 09:49:54 -0800 (PST)
Received-SPF: pass (google.com: domain of srs0=v3g0=qo=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of srs0=v3g0=qo=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=V3g0=QO=goodmis.org=rostedt@kernel.org"
Received: from gandalf.local.home (cpe-66-24-58-225.stny.res.rr.com [66.24.58.225])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id BF3762083B;
	Thu,  7 Feb 2019 17:49:51 +0000 (UTC)
Date: Thu, 7 Feb 2019 12:49:49 -0500
From: Steven Rostedt <rostedt@goodmis.org>
To: "Edgecombe, Rick P" <rick.p.edgecombe@intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "peterz@infradead.org" <peterz@infradead.org>,
 "linux-integrity@vger.kernel.org" <linux-integrity@vger.kernel.org>,
 "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>,
 "daniel@iogearbox.net" <daniel@iogearbox.net>, "jeyu@kernel.org"
 <jeyu@kernel.org>, "tglx@linutronix.de" <tglx@linutronix.de>,
 "linux-mm@kvack.org" <linux-mm@kvack.org>, "nadav.amit@gmail.com"
 <nadav.amit@gmail.com>, "dave.hansen@linux.intel.com"
 <dave.hansen@linux.intel.com>, "Dock, Deneen T" <deneen.t.dock@intel.com>,
 "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>,
 "linux-security-module@vger.kernel.org"
 <linux-security-module@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>,
 "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hpa@zytor.com"
 <hpa@zytor.com>, "kristen@linux.intel.com" <kristen@linux.intel.com>,
 "mingo@redhat.com" <mingo@redhat.com>, "linux_dti@icloud.com"
 <linux_dti@icloud.com>, "luto@kernel.org" <luto@kernel.org>,
 "will.deacon@arm.com" <will.deacon@arm.com>, "bp@alien8.de" <bp@alien8.de>,
 "kernel-hardening@lists.openwall.com"
 <kernel-hardening@lists.openwall.com>, "mhiramat@kernel.org"
 <mhiramat@kernel.org>, "ast@kernel.org" <ast@kernel.org>,
 "paulmck@linux.ibm.com" <paulmck@linux.ibm.com>
Subject: Re: [PATCH 16/17] Plug in new special vfree flag
Message-ID: <20190207124949.0ea219a7@gandalf.local.home>
In-Reply-To: <16a2ac45ceef5b6f310f816d696ad2ea8df3b45c.camel@intel.com>
References: <20190117003259.23141-1-rick.p.edgecombe@intel.com>
	<20190117003259.23141-17-rick.p.edgecombe@intel.com>
	<20190206112356.64cc5f0d@gandalf.local.home>
	<16a2ac45ceef5b6f310f816d696ad2ea8df3b45c.camel@intel.com>
X-Mailer: Claws Mail 3.16.0 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 7 Feb 2019 17:33:37 +0000
"Edgecombe, Rick P" <rick.p.edgecombe@intel.com> wrote:


> > > ---
> > >  arch/x86/kernel/ftrace.c       |  6 +--  
> > 
> > For the ftrace code.
> > 
> > Acked-by: Steven Rostedt (VMware) <rostedt@goodmis.org>
> > 
> > -- Steve
> >   
> Thanks!

I just noticed that the subject is incorrect; It is missing the
"subsystem:" part. See Documentation/process/submitting-patches.rst

-- Steve


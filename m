Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 37968C31E5E
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 15:50:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 06CAE2166E
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 15:50:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 06CAE2166E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 967C68E0002; Tue, 18 Jun 2019 11:50:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 917A28E0001; Tue, 18 Jun 2019 11:50:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7DF378E0002; Tue, 18 Jun 2019 11:50:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5A8AB8E0001
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 11:50:13 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id q26so12828237qtr.3
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 08:50:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:date:message-id:user-agent:mime-version;
        bh=u3DxXnn/aVB8Gzqg83K/P+ZrSDD5XNARdQd98eOAH/U=;
        b=bHElg6IHQ+R9vp6Zz5V3YBJaCfUvA4JoqnqlyQZQAJTDE8KOnSLg8OVKwNVhJbWG3/
         BIp0Y9hhapkb2OTOsk+m4qr1KDlhTg4LOt4aSYcOmVuxki2zRI/8+AEoAmxxKugvsMXW
         zOOM8+DENIbX24RrWhtuDUQCWIVyku3MWdqZXkzCm8C24rBtx+egcSYiPI/Yj4wbIxMC
         Sk3QUaF5oHm5EyqKycm0duLKjmVoBzog0lT6yQjzS7vnYzCgAM8sAKDvQgeTNcZ79xis
         jw4G85FeS/mW3YJ85bL4phpbKJhtFq1POParOVbA2L5e+eN+WyW78xz5YLSSckXHvUkM
         5Okg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of fweimer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=fweimer@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUuOSd4ReG1MAcZ8vlZn6x/1Dob7hK93OOEWiG4HM6JnTzfJRvO
	/Xf4P9aWunXzCApDw2O3DiIhyaUDm+Ttizxppear3o8lkvh/JUsLSUYA9x2s9JCgKV8FJ8Gqc5Q
	Jlr1vwerhi1femcG+BmBcycoFc5HVJOHKiy0zEm/6EHIOq5zP6gemlVcxBsw+rF9+BQ==
X-Received: by 2002:ac8:2848:: with SMTP id 8mr94696074qtr.216.1560873013170;
        Tue, 18 Jun 2019 08:50:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzYmkMvnjdmI5eSLgXVBMO9qRN19ODfM6PF2r8f+qz/nixRSnBY/jrvleM4Tu0MwD4mUm+R
X-Received: by 2002:ac8:2848:: with SMTP id 8mr94696025qtr.216.1560873012647;
        Tue, 18 Jun 2019 08:50:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560873012; cv=none;
        d=google.com; s=arc-20160816;
        b=SnnP8VlOV7gma7geiFiSNo6e7oOpgLi+w08j4lLKaziKoikajAgt5F4ptSQmNrem9B
         P1PGoFdZ8U2q/f37FPQYSKDTo3tpLGLBMuv+g1I/W7GZx0OxYmH9ITt2mUZj+BnouQQY
         S2/GPXHBAtuRxb7jqAmkDhbnf5o4e457zKlhls2g6Gfve4Vl7Rd75kXIPklU0GLZ5xQn
         3RCasU/WP7jDPEu3njlbUAuFlQVMhxmuhYkZVFnPgGi2C5CLRoCs0Pg201IBeua96MEC
         9uanHYHS8p+9us2v066cL8WV5v+pW0Z6oSbwbjs7sdiY2WCv6vL206l05U286lrICVsV
         D4ow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:date:references:subject:cc:to
         :from;
        bh=u3DxXnn/aVB8Gzqg83K/P+ZrSDD5XNARdQd98eOAH/U=;
        b=VejovKUVEnB0lPq0gSZ6XXoUy6J4xrCPI9zneNmT7Lvx0QWkXc6qLz4I16DG4ptIIc
         GIWa2u89+ITK7vW+yC4MQtHuEplZ7LoJq0/E2dnGkKZhrzcmIjTfn9a2qRXtOaFjnKTG
         ZPAmmd+I3e9iyRxxICG5ufga7b5v6eKyYvRW4/+3fzGbXHcu54RPCM0NGpK2sqkTzdO3
         NCQrMl2g3TPTTgPaIMqYnjZ0EhtmAliUe2XFiq05JMd5/IdAmdhbFrMFuVoj2/uI+0b1
         1U7bnMRvzUJ8XMpMGt6vWIB7mJyXkuxQvXE8AfE8M7bz+BaYYH49HTXBm2loGl1renoD
         QUxA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of fweimer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=fweimer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v23si442155qto.398.2019.06.18.08.50.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jun 2019 08:50:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of fweimer@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of fweimer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=fweimer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 5D2F530C0DE3;
	Tue, 18 Jun 2019 15:50:09 +0000 (UTC)
Received: from oldenburg2.str.redhat.com (ovpn-116-87.ams2.redhat.com [10.36.116.87])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 15A245C2E4;
	Tue, 18 Jun 2019 15:49:51 +0000 (UTC)
From: Florian Weimer <fweimer@redhat.com>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: Dave Martin <Dave.Martin@arm.com>,  Peter Zijlstra
 <peterz@infradead.org>,  Thomas Gleixner <tglx@linutronix.de>,
  x86@kernel.org,  "H. Peter Anvin" <hpa@zytor.com>,  Ingo Molnar
 <mingo@redhat.com>,  linux-kernel@vger.kernel.org,
  linux-doc@vger.kernel.org,  linux-mm@kvack.org,
  linux-arch@vger.kernel.org,  linux-api@vger.kernel.org,  Arnd Bergmann
 <arnd@arndb.de>,  Andy Lutomirski <luto@amacapital.net>,  Balbir Singh
 <bsingharora@gmail.com>,  Borislav Petkov <bp@alien8.de>,  Cyrill Gorcunov
 <gorcunov@gmail.com>,  Dave Hansen <dave.hansen@linux.intel.com>,  Eugene
 Syromiatnikov <esyr@redhat.com>,  "H.J. Lu" <hjl.tools@gmail.com>,  Jann
 Horn <jannh@google.com>,  Jonathan Corbet <corbet@lwn.net>,  Kees Cook
 <keescook@chromium.org>,  Mike Kravetz <mike.kravetz@oracle.com>,  Nadav
 Amit <nadav.amit@gmail.com>,  Oleg Nesterov <oleg@redhat.com>,  Pavel
 Machek <pavel@ucw.cz>,  Randy Dunlap <rdunlap@infradead.org>,  "Ravi V.
 Shankar" <ravi.v.shankar@intel.com>,  Vedvyas Shanbhogue
 <vedvyas.shanbhogue@intel.com>
Subject: Re: [PATCH v7 22/27] binfmt_elf: Extract .note.gnu.property from an ELF file
References: <87lfy9cq04.fsf@oldenburg2.str.redhat.com>
	<20190611114109.GN28398@e103592.cambridge.arm.com>
	<031bc55d8dcdcf4f031e6ff27c33fd52c61d33a5.camel@intel.com>
	<20190612093238.GQ28398@e103592.cambridge.arm.com>
	<87imt4jwpt.fsf@oldenburg2.str.redhat.com>
	<alpine.DEB.2.21.1906171418220.1854@nanos.tec.linutronix.de>
	<20190618091248.GB2790@e103592.cambridge.arm.com>
	<20190618124122.GH3419@hirez.programming.kicks-ass.net>
	<87ef3r9i2j.fsf@oldenburg2.str.redhat.com>
	<20190618125512.GJ3419@hirez.programming.kicks-ass.net>
	<20190618133223.GD2790@e103592.cambridge.arm.com>
	<d54fe81be77b9edd8578a6d208c72cd7c0b8c1dd.camel@intel.com>
Date: Tue, 18 Jun 2019 17:49:50 +0200
Message-ID: <87pnna7v1d.fsf@oldenburg2.str.redhat.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.2 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.45]); Tue, 18 Jun 2019 15:50:11 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

* Yu-cheng Yu:

> The kernel looks at only ld-linux.  Other applications are loaded by ld-linux. 
> So the issues are limited to three versions of ld-linux's.  Can we somehow
> update those??

I assumed that it would also parse the main executable and make
adjustments based on that.

ld.so can certainly provide whatever the kernel needs.  We need to tweak
the existing loader anyway.

No valid statically-linked binaries exist today, so this is not a
consideration at this point.

Thanks,
Florian


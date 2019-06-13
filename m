Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 591F6C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 06:48:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 143ED206E0
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 06:48:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="nZ7PQjew"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 143ED206E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9814D6B0003; Thu, 13 Jun 2019 02:48:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9323F6B0005; Thu, 13 Jun 2019 02:48:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 820846B0006; Thu, 13 Jun 2019 02:48:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com [209.85.167.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1F55B6B0003
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 02:48:20 -0400 (EDT)
Received: by mail-lf1-f71.google.com with SMTP id j27so3119270lfh.4
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 23:48:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=lv9nqSLtCZiZ8ahiodoBv8WyJCmSbiyt0thoq18zE4o=;
        b=lqUH0DRlFmJLmSl4XALM5Il+fo7xAzUpubVLLF+qshnLdPra1AITGBJZprIZ+a69Cb
         HfLFPGCfS64Z+D53mh9UzZugs3BGsablGEYZXv4agR1eWRtqwL/wVfJpVlF7/rXZYgQO
         Q0LpT5x7WWBWlaz4P5SrxQQ8pGqvJDnSMk2+ZPi5nmfuYhcz8DSBNk+O3geFmfLF+Dy3
         PmJs7nh/AGE5oPmEj6oeqGsgeNemINxEIRqnhC4qu2f4CtYxJgSZ/CYRJidxC++I2khT
         QCAPZMuh1Nh40e8a8KYRV/3Ft/I5aqNM7YVIVE4ielt8iezNwgyYdmWwRSZQPMqlnkRe
         UbYw==
X-Gm-Message-State: APjAAAVWZ/qeJVKIqS+yH1Qdc6GB3KPYJGHN9Kjrtutzd0pLNJiyLQhA
	2h4pF2qPcYBiEF9EofmWMCrVtcQ1KDRZgWrysSX4ZKtNVZJ5ujcWq0ps1PdRozyY+3o8Mt4VzzN
	iBW+sDwjJAD93BjDiMhKM5JLjFKMtsGrD43QkaFfe1tTw0x8uSZs/B5vO0Jh7srtYIw==
X-Received: by 2002:a2e:9c85:: with SMTP id x5mr8305718lji.139.1560408499459;
        Wed, 12 Jun 2019 23:48:19 -0700 (PDT)
X-Received: by 2002:a2e:9c85:: with SMTP id x5mr8305681lji.139.1560408498610;
        Wed, 12 Jun 2019 23:48:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560408498; cv=none;
        d=google.com; s=arc-20160816;
        b=DHl+eTrU0BBo6ynZ1pZg1ODMQJDnGf/Cizh2/RB10Lm2JFm3cMoyEBpo8HNW+laXmE
         7/5Q2h5JSOrr7jvR67yIAODFQ7lgIsGl7Mcve4hZqWLlp48A9sA9MH8oblcykVDM/0gv
         QkznegqtIAPYawgviduHFerPmLycnaVpeFuRJP+eDLzZhmLDEvEaXBn8JrEZ6huqzcSx
         e2d3vWJ5NndnJx3QjQkzod9IwncsQKp3rfN77vLYI06FM8+QXUi+nviJA7cq2KCAq+M2
         wEpOar/9OI1Qfe7oy8ltEkh73TkplP343bJA7Y4Gd0rhI8quC6/aBfZSEeTUljZ1aJaF
         TlGA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=lv9nqSLtCZiZ8ahiodoBv8WyJCmSbiyt0thoq18zE4o=;
        b=mdnDPlrDfVsbp4+qTX00UC5MT19zp2mG124JGSAE+Hfuo5IlgQYu/cPTE2w2pG64b8
         pL5xvDUsqMfRm+mm5vNUdUXmIinx0zX+v1f6bib8uFxRHknhhmI6gUThl0PN3zZbL/uN
         7nTowzX0Gr2D7miI/hCVHQDskwdJWSFungdKad2hroVfM7V4W8urbmlG0usEC/Pf5T4g
         woeckUKsIu1GHHA0P4IefCg1w1DOKLSA/ybvpIY0IiDq90i5/xFTrydXUK65nrwzozI0
         j4MSTr30Uk8ra1IsBLCu6UcyNz+lwKoUzYi6qEnylFG9m1SNu/I/nUHpGgofNkWqLSgA
         zeRg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=nZ7PQjew;
       spf=pass (google.com: domain of gorcunov@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=gorcunov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p5sor1238361ljp.3.2019.06.12.23.48.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Jun 2019 23:48:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of gorcunov@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=nZ7PQjew;
       spf=pass (google.com: domain of gorcunov@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=gorcunov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=lv9nqSLtCZiZ8ahiodoBv8WyJCmSbiyt0thoq18zE4o=;
        b=nZ7PQjewhkNFLJJFS9CWkoOR/2SEzVmnFe8JrDQZP9WGcZpfUm4TWzaVR34kqgOkM6
         PSejsxPi0NXyf4QlD5sX4JIbnQfXedVnig36j74X1SFYqDWGSabvXNjxjGVLIXkawcuU
         FLxHCMmbItnJk/+HFhcv2buBYqTCBeda6PFTmID1zVJDHxvH+2FvmDkY//qUdtytA1rY
         XAU372/eZO1vArF8Nvb3ESlmzJwhIz6vNWOMU+IhBUUih36nYQRORDh23Fhe5qPHSqz9
         W5zZSLTxbnEjMPo5VqL3HJlKMAhbO5g/ZW2HDfLWl0duR2ldpc2FeL0NApW675/Lripg
         kkbA==
X-Google-Smtp-Source: APXvYqy6FpZw7RE8ERzs0oPq21ly6eN+8mWADKZTvCK7LLigk9bmBzrjxoFEZnOBRpHWrUPHGL4mfA==
X-Received: by 2002:a2e:2c07:: with SMTP id s7mr6057511ljs.44.1560408498002;
        Wed, 12 Jun 2019 23:48:18 -0700 (PDT)
Received: from uranus.localdomain ([5.18.102.224])
        by smtp.gmail.com with ESMTPSA id y18sm396934ljh.1.2019.06.12.23.48.17
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 12 Jun 2019 23:48:17 -0700 (PDT)
Received: by uranus.localdomain (Postfix, from userid 1000)
	id D702646019C; Thu, 13 Jun 2019 09:48:16 +0300 (MSK)
Date: Thu, 13 Jun 2019 09:48:16 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
To: Andrei Vagin <avagin@gmail.com>
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, Oleg Nesterov <oleg@redhat.com>,
	Matthew Wilcox <willy@infradead.org>,
	Michal Hocko <mhocko@kernel.org>,
	Kirill Tkhai <ktkhai@virtuozzo.com>,
	Michal =?iso-8859-1?Q?Koutn=FD?= <mkoutny@suse.com>,
	Al Viro <viro@zeniv.linux.org.uk>, Roman Gushchin <guro@fb.com>,
	Dmitry Safonov <dima@arista.com>
Subject: Re: [PATCH v2 5/6] proc: use down_read_killable mmap_sem for
 /proc/pid/map_files
Message-ID: <20190613064816.GF23535@uranus.lan>
References: <156007465229.3335.10259979070641486905.stgit@buzz>
 <156007493995.3335.9595044802115356911.stgit@buzz>
 <20190612231426.GA3639@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190612231426.GA3639@gmail.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 12, 2019 at 04:14:28PM -0700, Andrei Vagin wrote:
> On Sun, Jun 09, 2019 at 01:09:00PM +0300, Konstantin Khlebnikov wrote:
> > Do not stuck forever if something wrong.
> > Killable lock allows to cleanup stuck tasks and simplifies investigation.
> 
> This patch breaks the CRIU project, because stat() returns EINTR instead
> of ENOENT:
> 
> [root@fc24 criu]# stat /proc/self/map_files/0-0
> stat: cannot stat '/proc/self/map_files/0-0': Interrupted system call
> 
> Here is one inline comment with the fix for this issue.
> 
> > 
> > It seems ->d_revalidate() could return any error (except ECHILD) to
> > abort validation and pass error as result of lookup sequence.
> > 
> > Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> > Reviewed-by: Roman Gushchin <guro@fb.com>
> > Reviewed-by: Cyrill Gorcunov <gorcunov@gmail.com>
> > Reviewed-by: Kirill Tkhai <ktkhai@virtuozzo.com>
> 
> It was nice to see all four of you in one place :).

Holymoly ;) And we all managed to miss this error code.
Thanks, Andrew!


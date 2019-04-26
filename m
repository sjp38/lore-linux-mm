Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F1B73C43219
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 07:50:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B3960206E0
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 07:50:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Op/BtNTT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B3960206E0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3DB916B028F; Fri, 26 Apr 2019 03:50:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3B0A96B0292; Fri, 26 Apr 2019 03:50:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2A0936B0293; Fri, 26 Apr 2019 03:50:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id E32D66B028F
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 03:50:02 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id n10so405284pgg.11
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 00:50:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=slE4aT5ZNj8dJtxH+FhGBwyu8kafNxlAmX6nDldrcS4=;
        b=CxOnKQUxQKy23vU9BJwCi+KgCZjlW+FJvS8o7WZ6LoAHcyR39Xpz/oWn8EmxxylNOE
         Wj6LT4smWqt9jceiQG2meEpKmwAY0q41wf85g3Kj+rTJJqzlK/KQayWFHr2hI0ZPrP7Q
         I7CYm1TxEhsr4pIPKT0S1NHao4IL5sGhLdzd3DmATkJHHZjC72hsGiuLzDnwWdECoqCH
         lVaoTMsJLmWYldQN2qvVsnlM1k3mp0ELi+nJAHIPEf2DxaxxLKvOs5RXKfLoR4PPxNFr
         xOXZ1JZH/fcZ3CpVqyPK3rSCEqJeCUWVvgIWYe1iKsBmgfGoa5JnTySzmPJswctV1rJP
         F2tQ==
X-Gm-Message-State: APjAAAWFkcLZbCCA0w4Qh+1Rf7LaUkSmtd2sorwnV0p5F+gUBXoLl0Bc
	Mq/4dGrUudVkOxj7RMBlUdiiWJoF5Kjq3f6IncGjCpgpq6dNtVDFWm7atiy89gefofAixyX1Vos
	OKU6aPe4RHruYUfiGdLzHZ43YSw5qxbMK78eXgtTfc16B80Kqh7lcfQe7NEB4qxB8Ow==
X-Received: by 2002:a17:902:bd92:: with SMTP id q18mr44908141pls.136.1556265002588;
        Fri, 26 Apr 2019 00:50:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx0OxPTBWyYoQKQuVHJw5BUowS5Z23TJwQLB4e1pFEnpZ/U8WQ28rKLoqOomj45ZSDFLXJ3
X-Received: by 2002:a17:902:bd92:: with SMTP id q18mr44908097pls.136.1556265001843;
        Fri, 26 Apr 2019 00:50:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556265001; cv=none;
        d=google.com; s=arc-20160816;
        b=xi0J+WCJzcsTdpbp+jjQ0VnwnGpjxd6KT7csHS+YSsyT5MThIgipm6EZbNUPjzLGig
         D1WlcfFc75bRz3FxVkL4bhHAh8IxHJG49fvTWxzyvOaikh9XIkqS9/Ii2l586WkzcDI5
         UkU41f/LpRlLDm1x3fiv6GZA20Y1wzGPWC28MU2RYT1kNYn/wyf/lSDMc+ag5O4tSdJH
         41vW/1qGWGvb+ug/ZN70FMFsHXG8p5WZsgue6qi6Na4Oh/cvYvBzFOmIbMQt1Fp9wCj5
         bQrmvCbuCx0zbrOgRbDIIVa4fymzrTUdOgDiXIDERI8+Plq0XaB+TTISbhdexm/vWq3U
         9Jnw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=slE4aT5ZNj8dJtxH+FhGBwyu8kafNxlAmX6nDldrcS4=;
        b=nA76w4Hmg52O4rezFVflMOx6VbZuE5kXezLnHHj7KaiQvLnMSkOasxBFTewoLiZIcl
         MvYPZGy0TadMooAEn0ujsiMcaRXk+1MQvOfpJAIZbSdDOXuQEvbIztBENe2VqJ2WfiGy
         SK/4yl90ABwIGhtE+yf4ADv04CYDdx1W+b3IkLbaEPcrwHZWYxjPQfYXtz2VO/u22lLP
         aGhGL5rPiEcza6BG+RKBY40oafVfmKahJTYwb3a9CTheWZ6S4wxl0t4ivJrucQKLk2YV
         q0hG4duXUIEXPpQVnhavdhnJbwTwb5N91yr7kJoHLeQGVc9GBT/cuz+MyJ9SQUNH6kBx
         jMXw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="Op/BtNTT";
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id q1si25013786pgh.396.2019.04.26.00.50.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 26 Apr 2019 00:50:01 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="Op/BtNTT";
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=slE4aT5ZNj8dJtxH+FhGBwyu8kafNxlAmX6nDldrcS4=; b=Op/BtNTTdoi+lOukFcWX4choG
	882I7O1OKUeSfugw5FDEE8frhdfBaCMcWl7hiSMX4nAWztIGM/B8ibBqKFJCnPoXp3/kDy8rx4YhC
	uvUqRvrvrWFh2fq+KduiKrBv0H3yBWK9oBjFXVmqQdGZjrNASCAJ2og1IxUQGRcYMRhDFVfDSZfT+
	4VC6UmQw9hJk/NJjOjl6W/Xu0rWytUIlcVnGCFV7+DZT3hSVyFwowHpwdkK1vdxZB0t5myzQODMOg
	8HwgOCiydPFYEFjDX9PDp1qRkAhAtoU1oxTNk4Jif8MITPXfuFbirlP9K0Wd7JE+ALAjgNBoFEtto
	wg1bodvqA==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hJvcM-0000zs-Bl; Fri, 26 Apr 2019 07:49:58 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id B4A6F29D1A323; Fri, 26 Apr 2019 09:49:56 +0200 (CEST)
Date: Fri, 26 Apr 2019 09:49:56 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: linux-kernel@vger.kernel.org,
	Alexandre Chartre <alexandre.chartre@oracle.com>,
	Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	"H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>,
	James Bottomley <James.Bottomley@hansenpartnership.com>,
	Jonathan Adams <jwadams@google.com>,
	Kees Cook <keescook@chromium.org>, Paul Turner <pjt@google.com>,
	Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org,
	linux-security-module@vger.kernel.org, x86@kernel.org
Subject: Re: [RFC PATCH 2/7] x86/sci: add core implementation for system call
 isolation
Message-ID: <20190426074956.GZ4038@hirez.programming.kicks-ass.net>
References: <1556228754-12996-1-git-send-email-rppt@linux.ibm.com>
 <1556228754-12996-3-git-send-email-rppt@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1556228754-12996-3-git-send-email-rppt@linux.ibm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 26, 2019 at 12:45:49AM +0300, Mike Rapoport wrote:
> The initial SCI implementation allows access to any kernel data, but it
> limits access to the code in the following way:
> * calls and jumps to known code symbols without offset are allowed
> * calls and jumps into a known symbol with offset are allowed only if that
> symbol was already accessed and the offset is in the next page
> * all other code access are blocked

So if you have a large function and an in-function jump skips a page
you're toast.

Why not employ the instruction decoder we have and unconditionally allow
all direct JMP/CALL but verify indirect JMP/CALL and RET ?

Anyway, I'm fearing the overhead of this one, this cannot be fast.


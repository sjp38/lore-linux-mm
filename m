Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ECCE3C76186
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 17:17:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B46C620840
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 17:17:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B46C620840
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 484BA8E000A; Wed, 24 Jul 2019 13:17:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 436848E0005; Wed, 24 Jul 2019 13:17:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 324978E000A; Wed, 24 Jul 2019 13:17:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0B5D38E0005
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 13:17:48 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id r7so24512661plo.6
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 10:17:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=v5o93rppXWOEe1khDbdKPwUWVhMWimUKdS1T4a7dv9A=;
        b=tMggVsgnK24eNFPzA6cgxUJg41Um0RCFQ6VEyRRszjKnin5tslBPro5rtt0gZB8fMp
         f6K+5BzWJKPJouIMXOqmJ/uJ+EAWENCa5Y7XLjak7a3DzD1MdyaEiN+lXjhI/VYTX7Vq
         +4jCKxqgeuyGoNiqaSngcV2AbdpdnUibY4v6iDTWgG3c/vbht62ZHEZ7S9c/CYq2onEd
         uTF4/KbCsHe3APTnZ/H3gFqg1FpDVm8iETDfG3hDpSF5UegR6ToykqpidM3Iy56vB52Y
         vlikHzq3Yt9sBlRe4lrZxItsEKORjSCbyoNQRKkxHIZ6HffA7og3VvpbnmV6NN2pBe9f
         BUPg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mcgrof@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mcgrof@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXGo0wBg+7ZZVCtr+vA5maegBKMjm8W2WAPiO8I4yVmcJapCGvD
	QAp8BDUJSY3GRa21AZbO0rSYBLLMJMnZ0YoKNYH14Z72KzUc62jT3pGeMjXg8AOqxskJcQ2Tz17
	p7A9LB3bLgmo4ySRVv75Tkt38dFUxbugHUUOm3cvYEvfhZrfBGGxStl9CN9Ysl3k=
X-Received: by 2002:a63:d002:: with SMTP id z2mr84483340pgf.364.1563988667655;
        Wed, 24 Jul 2019 10:17:47 -0700 (PDT)
X-Received: by 2002:a63:d002:: with SMTP id z2mr84483297pgf.364.1563988667047;
        Wed, 24 Jul 2019 10:17:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563988667; cv=none;
        d=google.com; s=arc-20160816;
        b=0+5yqVXyqZJ7pqL9+Tf5IrWWsb5k9lSmbL+gn4ijSy7CCr+dMQkIyWOuZ6V/isdPGt
         3YS1ljP6igfoynbWxCVeE/9/38dlen4GTPOcIAg2a4Ixfk0X0Yk5z8Qg9MfG0MaZ5Mjt
         b6nm/V4vKvIiqtA6Pb2pb5RNW8PEQ8TSTTfw2bdBFUc6DdJZWoh/TCnpQIq6ULpdOMjm
         tPaZHQRwYeqvGfNZOFEuCZgUqED8e1QyD+sfH4JSTjo5Lan0L/lFcM5Mt9wNrMtIg9ty
         riPNlFQyHYwq2CoWPRQ4eNYZ+T+xzhU1GGgywzNCsm9t945qyZb3Rtf/XDSK5SQRlu1A
         ZTHg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=v5o93rppXWOEe1khDbdKPwUWVhMWimUKdS1T4a7dv9A=;
        b=hIt0bEMx3j1N5Fe5N0h7nHu50PEj1ipJqElTqN7uBZU5YYEF1EFknOzTTqwCbQtlTK
         NEFFqbYoYVDPjzaQBTLkioEgmTZ4Iuy7TXPy3wGc7NIkOdx2NocTjmzODdwCciMwjKq9
         YYUU0mTNBZj3P/brjCTFee7/tm6xWtHpQBIMQzisnf0UdC14vnYF3Q+e05gXdP1aqqTq
         4sZPYkumQoKqxwbeAzhY4o5/5kbnVwN6U4cRttNdwyRuLLh9Tq1oji4nQEaQJGZ2wIlE
         IiBQcNbPNx7yPbJbGoTUjBdjm0fWD8h9mrUhfEmUelPqhWKQXzZ3Avvi1Tk3+i0IyZ3N
         zYLA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mcgrof@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mcgrof@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a14sor57531058pjs.0.2019.07.24.10.17.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Jul 2019 10:17:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of mcgrof@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mcgrof@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mcgrof@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: APXvYqz8XfN6M40/6fe7BxMTCZJQCCPcbWguJPVyb/SH7u8lYYU33WfbbFpre78nAUrnVv5x6QkoeQ==
X-Received: by 2002:a17:90a:bd93:: with SMTP id z19mr89794097pjr.49.1563988666568;
        Wed, 24 Jul 2019 10:17:46 -0700 (PDT)
Received: from 42.do-not-panic.com (42.do-not-panic.com. [157.230.128.187])
        by smtp.gmail.com with ESMTPSA id t10sm46821994pjr.13.2019.07.24.10.17.45
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 24 Jul 2019 10:17:45 -0700 (PDT)
Received: by 42.do-not-panic.com (Postfix, from userid 1000)
	id 1E29A402A1; Wed, 24 Jul 2019 17:17:45 +0000 (UTC)
Date: Wed, 24 Jul 2019 17:17:45 +0000
From: Luis Chamberlain <mcgrof@kernel.org>
To: Alexandre Ghiti <alex@ghiti.fr>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Christoph Hellwig <hch@lst.de>,
	Russell King <linux@armlinux.org.uk>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	Paul Burton <paul.burton@mips.com>, James Hogan <jhogan@kernel.org>,
	Palmer Dabbelt <palmer@sifive.com>,
	Albert Ou <aou@eecs.berkeley.edu>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-mips@vger.kernel.org,
	linux-riscv@lists.infradead.org, linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH REBASE v4 00/14] Provide generic top-down mmap layout
 functions
Message-ID: <20190724171745.GX19023@42.do-not-panic.com>
References: <20190724055850.6232-1-alex@ghiti.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190724055850.6232-1-alex@ghiti.fr>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.002430, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Other than the two comments:

Reviewed-by: Luis Chamberlain <mcgrof@kernel.org>

  Luis


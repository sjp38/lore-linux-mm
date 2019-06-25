Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 525E9C48BD4
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 07:44:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1E2E52085A
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 07:44:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1E2E52085A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A98696B0003; Tue, 25 Jun 2019 03:44:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A484F8E0003; Tue, 25 Jun 2019 03:44:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 910568E0002; Tue, 25 Jun 2019 03:44:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5B3686B0003
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 03:44:26 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id i2so7540698wrp.12
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 00:44:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=7p01ZFEYPL8aGZEc1cwL0RHcx2GJwCziYOfKFVTLdSU=;
        b=Hh2A73K2vwVZLlWrg9CqSgz8ydpTFayozVjqOm6uS8DU76h5zxaf59jXJ9p5tphPvY
         GHb7oVio4+K8Ao8dBe+ldLPDfmkTcBbMUaZoun9C7sG+O0QHY0nynu6IunqybOLg+xbz
         SLVuiJNzvaWmLaj6IsNkq8PkULLhvruaPz0lMvNIYUldJH9hxewZLb5FUMwJMLXOClUP
         uAviIIW8YmAcdyMPsJ/IsjNTQ4R7PPmzyyzRE/Aj749jsJVGBCF3QUFSueUN484geP02
         1AGPkV20mlg5vt4EKp7NonSLEri8hRoH+yvOIrio6P9yA5RsinswewB2+dUMtoJYHXYj
         zq/Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAUNvLbWwXSGFpPChgQY/PfFFHuZd5DTIEx4M5y/DLw/wHhxospG
	rebgX5coouaWQUKHSfc9osoPjlzZSdsWF7heJiMkfH8VVJsKf6dMRgF1Td6LfTcqdbzYEopHfLl
	DtU1wk8hu+m59FXOo/J6GkPv7ZtBr7UiLOhOpzBvr9Jl5DZny/ITKjAHcHVC0/F2WwQ==
X-Received: by 2002:a5d:4708:: with SMTP id y8mr1578903wrq.85.1561448665979;
        Tue, 25 Jun 2019 00:44:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwen+f6kJ1YvYL0H+NMT0Rng/CxLc9/4ovbSMFb6fMqllsXunaizfWGO30KpjrITHFob4o2
X-Received: by 2002:a5d:4708:: with SMTP id y8mr1578864wrq.85.1561448665443;
        Tue, 25 Jun 2019 00:44:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561448665; cv=none;
        d=google.com; s=arc-20160816;
        b=D2cUSWnl+z8Q/a+VvSHlu5VsyecJIoPGIG71k0b4nwceTiGEmkpPyiPDLmwD2iJRS0
         r2XnyFyp4tfBy6EF75INqxJuSc8V+jgL0nP23uiZNi22k01aSW5dbY4fmwTxexds/7UG
         CKfZlW+kP+Aqda/NPRdNmMA5y2JHzHpVAoTqWrU9P09hqOZviEPODB71mEtcLbG9knsk
         gwzf3KbDSd9xg045/ydogcgUsy0AsBzNg2pjJcJ0b1KwrZEKR8A3GJJaCgxPA5t965tv
         97uzbI4f+Qqw44qhmr4zfLEwQaYafea0snPAjleYK2t+uWfnsRbXB8NLYgGhvnF14BSo
         uNfg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=7p01ZFEYPL8aGZEc1cwL0RHcx2GJwCziYOfKFVTLdSU=;
        b=GLZpCYmmEAvybfM6tQuRpViDkj7doteOW4Kv+cpuFwdqRX67plLUwHIL0X2zQ499Vf
         lKVQip7i4iMML0+4q6Gmvu8y8gCDlu1XlEOGg/vFTAq1gJu1hvbrcVRHtGf7t7GD13TH
         xlJnjjGQM9N3IkN0JOOmEYWbL8PAeKff6Ma8IsRfscRjjglcWGiJc0fX1ZbT0Q0NBFy8
         ChNV/Ap6IvmjHStH572fDyXiePQQrNHxzeRReijpDlcvGI1fScqrr1xVhG5c+CdPM00d
         T3XVpbia8a4H9T6v+lqLVhpUg+sxzn0k5HYUFHeGIQHN4qtvCZPbSpGOoPYU/YyIzfh7
         818g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id b9si11730702wrj.441.2019.06.25.00.44.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 00:44:25 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id 5891C68B02; Tue, 25 Jun 2019 09:43:54 +0200 (CEST)
Date: Tue, 25 Jun 2019 09:43:53 +0200
From: Christoph Hellwig <hch@lst.de>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Christoph Hellwig <hch@lst.de>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Paul Burton <paul.burton@mips.com>, James Hogan <jhogan@kernel.org>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Rich Felker <dalias@libc.org>,
	"David S. Miller" <davem@davemloft.net>,
	Nicholas Piggin <npiggin@gmail.com>,
	Khalid Aziz <khalid.aziz@oracle.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Michael Ellerman <mpe@ellerman.id.au>, linux-mips@vger.kernel.org,
	linux-sh@vger.kernel.org, sparclinux@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 01/16] mm: use untagged_addr() for get_user_pages_fast
 addresses
Message-ID: <20190625074353.GC30815@lst.de>
References: <20190611144102.8848-1-hch@lst.de> <20190611144102.8848-2-hch@lst.de> <20190621133911.GL19891@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190621133911.GL19891@ziepe.ca>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 21, 2019 at 10:39:11AM -0300, Jason Gunthorpe wrote:
> Hmm, this function, and the other, goes on to do:
> 
>         if (unlikely(!access_ok((void __user *)start, len)))
>                 return 0;
> 
> and I thought that access_ok takes in the tagged pointer?
> 
> How about re-order it a bit?

Actually..  I we reorder this we'd need to to duplicate a few things
due to the zero/negative length checking.  Given the feedback from
Khalid I'd thus rather skip the reorder for now.  If we have a good
reason we could add it back, but it would be a bit involved.


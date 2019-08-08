Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AF3CEC32751
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 01:49:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7B878217F5
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 01:49:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7B878217F5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=zeniv.linux.org.uk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1A2FB6B0003; Wed,  7 Aug 2019 21:49:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 153906B0006; Wed,  7 Aug 2019 21:49:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 06A106B0007; Wed,  7 Aug 2019 21:49:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id AF9D86B0003
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 21:49:45 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id b12so57197886ede.23
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 18:49:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent:sender;
        bh=InCKXOw6AuZjIPW7slpgV8NfAsadNpGEnBH/9CmOqnk=;
        b=cl7s4h218BVTU3knZc2ric3kEzfrpuaRYtQkhiVxG2f0Q2eqYStSs5uVY5YInc0w7T
         yOXjsp/xDsRhuU2r9ZSMcYxV5e8Uq321LyR7pepgn2hkvwOdgmlQEvmhDvkZ+YZyJHTF
         fw9zmy2MuLaGfiPc3kqHBVlDTCeEoKpOsur0Dw5dxXmVOckJmdRK+4pY7cKsJygfM/Kt
         DsBV1r5gOfmQ91Qa5rZpFE3fQo9jwuuw+M6NLqiirnvj1EcHuCBRF2U5461GuWozKduR
         MTiEGqmjyfNAwH7yj0CMZEMUp310Cnzv67x6rjrBedPKKARWpO5xRWdYF8dF3QuDFRM/
         eSGQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) smtp.mailfrom=viro@ftp.linux.org.uk
X-Gm-Message-State: APjAAAUDM+Wwqm9CBhmDBN7N7UPAIRazR3+PA0BdpFT39aca9VuEA4KG
	8xxNg3lCdX1atwFmOhPJnXRAXoZRNVhhFF7BoDaBlQ/jakjmUSCEmaiEtpRW5nmYcA6J1P92gsI
	iY90g0ALhazbzyQfuXEhCfygzPPJMVadlekUNfOIo9pq7h7jVUcQ0YYCb2E8h+FAnxA==
X-Received: by 2002:a50:f49a:: with SMTP id s26mr13173757edm.191.1565228985162;
        Wed, 07 Aug 2019 18:49:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyvHOE7aDJB1Uo5J4FHkmhNvWbkDZEQtTvgmCiZG8luHoqSD4LLsIFK50O3OykTO71uErVD
X-Received: by 2002:a50:f49a:: with SMTP id s26mr13173715edm.191.1565228984385;
        Wed, 07 Aug 2019 18:49:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565228984; cv=none;
        d=google.com; s=arc-20160816;
        b=rX5HHkBJ2/9KJWsF5Kg+8WQRo400vYXfUO/YIll8ISbon1fLi8XVACFBO+dazJSfJd
         nTr4k1wqVxJTwFOT8I1j9U1MFiwVIkYrbg8RjvcSo/iQyRbIY4TViCwGzIJo+O7/Zurj
         E1UnCDwOdETYFfbDwkASUClF6NlByvIvISVQ2ycB16FuEn4z90HTgRoT5Y3j0g3bNESO
         /JoCfltCnru07TDGdowNSUWagJNoYxZfv280qYHhnKDtoN7U7CMm78xxPABzZ5HnWhAu
         AsMuQjzLswFsDpYspFhyCXgKLUPCqOWNyrpVSk7+XXg1XCVxlknkBBLcXvmfaHxAxuaB
         k8PA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=sender:user-agent:in-reply-to:content-disposition:mime-version
         :references:message-id:subject:cc:to:from:date;
        bh=InCKXOw6AuZjIPW7slpgV8NfAsadNpGEnBH/9CmOqnk=;
        b=CRlehu6mx8LzJ9Wrr6lMfyFi4KUBgYdlGQUjrWhBqd+js2NOI++9pkY9D9DSrgsPyi
         vF4FtDua6ep2mEG6UMO84jGMAcFJvxkk1IiSuz5P9uTWS3+/0Zs5PT3VnHWhvqmqpxtx
         k/RuUuRGE7iEXoA6le2ShMiXvlDSwWqn8FpF8C7r4OS9BKsilfBHYFNZSzCb+oYwA2uX
         l4drW+JQ1J3Ibw5BB0v4/fIKAUZc0bSUXXaCJP5EBXHY/jpBM7GXIY2U/VHYMak/wOkn
         DE6WK7LZSu2brNT0EqkOJ6hx+vDna1MeYluIeT8ZS71gocwY0hRwpbty4jbXi+yXC0UH
         8LAA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) smtp.mailfrom=viro@ftp.linux.org.uk
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [195.92.253.2])
        by mx.google.com with ESMTPS id s43si33933201eda.175.2019.08.07.18.49.44
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 07 Aug 2019 18:49:44 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) client-ip=195.92.253.2;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) smtp.mailfrom=viro@ftp.linux.org.uk
Received: from viro by ZenIV.linux.org.uk with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hvXYT-00010L-MQ; Thu, 08 Aug 2019 01:49:26 +0000
Date: Thu, 8 Aug 2019 02:49:25 +0100
From: Al Viro <viro@zeniv.linux.org.uk>
To: Matthew Wilcox <willy@infradead.org>
Cc: syzbot <syzbot+3de312463756f656b47d@syzkaller.appspotmail.com>,
	allison@lohutok.net, andreyknvl@google.com, cai@lca.pw,
	gregkh@linuxfoundation.org, keescook@chromium.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-usb@vger.kernel.org, syzkaller-bugs@googlegroups.com,
	tglx@linutronix.de, Jiri Kosina <jkosina@suse.cz>
Subject: Re: BUG: bad usercopy in hidraw_ioctl
Message-ID: <20190808014925.GL1131@ZenIV.linux.org.uk>
References: <000000000000ce6527058f8bf0d0@google.com>
 <20190807195821.GD5482@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190807195821.GD5482@bombadil.infradead.org>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 07, 2019 at 12:58:21PM -0700, Matthew Wilcox wrote:
> On Wed, Aug 07, 2019 at 12:28:06PM -0700, syzbot wrote:
> > usercopy: Kernel memory exposure attempt detected from wrapped address
> > (offset 0, size 0)!
> > ------------[ cut here ]------------
> > kernel BUG at mm/usercopy.c:98!
> 
> This report is confusing because the arguments to usercopy_abort() are wrong.
> 
>         /* Reject if object wraps past end of memory. */
>         if (ptr + n < ptr)
>                 usercopy_abort("wrapped address", NULL, to_user, 0, ptr + n);
> 
> ptr + n is not 'size', it's what wrapped.  I don't know what 'offset'
> should be set to, but 'size' should be 'n'.  Presumably we don't want to
> report 'ptr' because it'll leak a kernel address ... reporting 'n' will
> leak a range for a kernel address, but I think that's OK?  Admittedly an
> attacker can pass in various values for 'n', but it'll be quite noisy
> and leave a trace in the kernel logs for forensics to find afterwards.
> 
> > Call Trace:
> >  check_bogus_address mm/usercopy.c:151 [inline]
> >  __check_object_size mm/usercopy.c:260 [inline]
> >  __check_object_size.cold+0xb2/0xba mm/usercopy.c:250
> >  check_object_size include/linux/thread_info.h:119 [inline]
> >  check_copy_size include/linux/thread_info.h:150 [inline]
> >  copy_to_user include/linux/uaccess.h:151 [inline]
> >  hidraw_ioctl+0x38c/0xae0 drivers/hid/hidraw.c:392
> 
> The root problem would appear to be:
> 
>                                 else if (copy_to_user(user_arg + offsetof(
>                                         struct hidraw_report_descriptor,
>                                         value[0]),
>                                         dev->hid->rdesc,
>                                         min(dev->hid->rsize, len)))
> 
> That 'min' should surely be a 'max'?

Surely not.  ->rsize is the amount of data available to copy out; len
is the size of buffer supplied by userland to copy into.

BTW, why is it playing those games with offsetof, anyway?  What's wrong
with
	struct hidraw_report_descriptor __user *p = user_arg;
	...
	get_user(&p->size)
	...
	copy_to_user(p->value, ...)


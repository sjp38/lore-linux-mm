Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B5455C32756
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 20:27:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 75F022173C
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 20:27:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="baL8kVkz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 75F022173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 169DD6B0003; Thu,  8 Aug 2019 16:27:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 11BD76B0006; Thu,  8 Aug 2019 16:27:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 009816B0007; Thu,  8 Aug 2019 16:27:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id C21796B0003
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 16:27:10 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id 191so59817892pfy.20
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 13:27:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=WTcQccWDVPotg15phg3zTAF2oauPTn+igOIs1LWZuPo=;
        b=B/9CMdjN1Q/77E6AATU3p9YWkZTDzVsadHrg1/rDQc8y7XoP+CebaA6m3zCQuzX99l
         Jb0zSEruJBzNcMeaaqLCg+MrcM8REGUBr6vmoZ8p2TYciSvOhlu3+rEuEr9bBbOLDBu8
         cbNBFObLHfYrmJSGxR1nMkQsF2MEIjk3gsnOqCmVmWv6Nnk/3arUZKyNT7wV2UTeeHL/
         tse2UEvfEyZfwobwivehdcfT7ilpXSlwmvne/LrhoNQoA22Z4w4mV7GxFQgDSSVpvMiN
         zepg7w7EILxIkFfYM4rYOtpdsu4Cd6LvaxM3f9L/2ThcZ98rSNn1uxIl3OuMAvfwR2OQ
         /NZw==
X-Gm-Message-State: APjAAAXZTEOTXsXTCvhBLefJTgKrOooKm710HDTPKNyitYMWjBmAbd9v
	9M0zJl2rScX/9bJLuiKZXjVtFz/IVWQNtUjtxSIf7fUBN+7kbvaDosqXVVFqG/DmwGs8NePms3p
	rb2nhKEFTpSHWKL4Kirdqti1lsKTqBCQzMZK11mZZ5MKRfti7C4haHnX91xBDVhLb2A==
X-Received: by 2002:a62:107:: with SMTP id 7mr17644531pfb.4.1565296030411;
        Thu, 08 Aug 2019 13:27:10 -0700 (PDT)
X-Received: by 2002:a62:107:: with SMTP id 7mr17644473pfb.4.1565296029649;
        Thu, 08 Aug 2019 13:27:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565296029; cv=none;
        d=google.com; s=arc-20160816;
        b=juvmwWSxevKo5R4fuf9yF05YHE2NoTxjQI/bh0aabuxRIvxjFUUzrD59cQ+yIePA++
         x2EeY1e9wSTMwtYFO+iaAmIUXDlcANmJirZIeC6ns+SW0ljh82buuCc2eUvHGVqeUyzQ
         /M6L3/8ouxTCrPjR/+xsaOV5OjiS5sLpbsn15NOzzC1GoX0EijfsvtxK2KNK1SMjY5Wv
         eBcm3KN3gk61cw2ouJDxCRmxp0vjUJkRJE1xKXJ/ZF9131BrlvzsLuW0Od2F5dhmv+nV
         /7yaUC45i8SyYQfdhuq6KyOE7hyyKTFlI/X1iDIkt20gub95HwnocizBEcGR/uc26G/5
         Sw+g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=WTcQccWDVPotg15phg3zTAF2oauPTn+igOIs1LWZuPo=;
        b=JA06dGmSx77VO8ISMU2uGgkV5wUL00LoZzy4WCA4a3H0irAvuKybal4dKTv+NE5OBf
         4wWEaYVJcLQ7ghE7G8sdD2znph2RMc4WDbR5NKpQgM4V2cjnc6J4hY6eQ1XhVBrO+eCF
         grZ23eGzz7rwC1svGzf0n1w5xrM3UJ1dcCkrJEv7gACHL2mE1CxlIpMghX74+gK01pn5
         rUqm2rCInunK9FjXue4XkAejS8nhkNxAt/P5DAhI+SmIK2xwzcUCqNtrQ5i2OUQzqewQ
         Wo57xwN4cVURiRo3Ax4OwWhD8k+cxE4iH+M0Wb24x7jGbyhXAoNLDGBvX3qM3OtaFXfl
         XyFA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=baL8kVkz;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o32sor113649700pld.12.2019.08.08.13.27.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 08 Aug 2019 13:27:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=baL8kVkz;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=WTcQccWDVPotg15phg3zTAF2oauPTn+igOIs1LWZuPo=;
        b=baL8kVkzYdf3Yw7iok/ISH9qw6Z5IgHF4JsMSBGfdZmgc/JdCO+HpcWQGGMZ/YHvH6
         SSVI1kBNX28mBZcYh+JlM/bQag427pRge8EruzV2ieAIq88fFgNsZ3WJqshOscuVs3Iz
         d3XBgLRYWP/OlBSFKX0cWHM3Fb5cJyhJJWQKs=
X-Google-Smtp-Source: APXvYqxwm9iB2DDzVLvhxV2ThVMadzVdxUASbdYGfIVkvlE3ECQjJubaoQGdIuoteqU4Z4An/jmJ/g==
X-Received: by 2002:a17:902:9a85:: with SMTP id w5mr15426653plp.221.1565296029267;
        Thu, 08 Aug 2019 13:27:09 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id 14sm93977517pfy.40.2019.08.08.13.27.08
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 08 Aug 2019 13:27:08 -0700 (PDT)
Date: Thu, 8 Aug 2019 13:27:07 -0700
From: Kees Cook <keescook@chromium.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: syzbot <syzbot+3de312463756f656b47d@syzkaller.appspotmail.com>,
	allison@lohutok.net, andreyknvl@google.com, cai@lca.pw,
	gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, linux-usb@vger.kernel.org,
	syzkaller-bugs@googlegroups.com, tglx@linutronix.de,
	Jiri Kosina <jkosina@suse.cz>
Subject: Re: BUG: bad usercopy in hidraw_ioctl
Message-ID: <201908081319.E2123D5A@keescook>
References: <000000000000ce6527058f8bf0d0@google.com>
 <20190807195821.GD5482@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190807195821.GD5482@bombadil.infradead.org>
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

This test actually contains an off-by-one which was recently fixed:
https://lore.kernel.org/linux-mm/1564509253-23287-1-git-send-email-isaacm@codeaurora.org/

So, this is actually a false positive if "ptr + n" yields a 0
(e.g. 0xffffffff + 1 == 0).

> ptr + n is not 'size', it's what wrapped.  I don't know what 'offset'
> should be set to, but 'size' should be 'n'.  Presumably we don't want to
> report 'ptr' because it'll leak a kernel address ... reporting 'n' will

Right, I left offset 0 (this is normally the offset into a reported area
like a specific kmalloc region, but isn't meaningful here IMO). And I
left the size as "how far we wrapped". (Which is pretty telling: we
wrapped 0 bytes ... *cough*.)

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
> 
> Jiri, this looks like it was your code back in 2007.

I think this code is correct and the usercopy reporting fix already in
-mm solves the problem.

-- 
Kees Cook


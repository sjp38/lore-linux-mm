Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A4C26C0650F
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 23:06:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 597872173C
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 23:06:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="ikTsZpqI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 597872173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E5FD06B0007; Thu,  8 Aug 2019 19:06:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E10786B0008; Thu,  8 Aug 2019 19:06:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CD8616B000A; Thu,  8 Aug 2019 19:06:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9566C6B0007
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 19:06:36 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id e25so60124511pfn.5
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 16:06:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=opDMrymB/En0zVOQAsZzeK0WBnbwyQ7DVo+LI/G+0nI=;
        b=i5+CZKAuSC9Dgg6HzCQhM67k8H7AOQwmxMrnFqpE8hTmy8HjyHL+z0wmClqnW42zch
         gaeCUgSFVtY5FA18B7cVKpgMr2EiBhX3Mb5/ddfhjaxrNNQc0dHc0w7qdJYJlBMW0sg9
         E4Wu8W34sCqIlOaHlnRQCJ79jrmVD13LekJ7nIPI8QVB9KCChJS7toJdMCVKAHTye5pK
         sJqpkwfN5qLOdEVoct3dH7cRpq6DEj0PYcaDuOhlTx+/0LJPXI34g/ucYWtN0EhhgoAi
         JD75Q4lESeZZ4g6Y5rf0c1gaaf6BtWd0HC0oTrJyWY2zfwg9wmXzsvli719Ubwd9T11M
         Pkvw==
X-Gm-Message-State: APjAAAVWhqZ8uHoPIWSac0rcMRqnczB2HAugZ5GNMPMM49xDc8UUwWmJ
	uks3nlEx5YI69snZBpb8OryILvr5UYHQEU/KX2tEcuqH9DJXNmpnIgu7VXUiN5n+vfPBG9TRV6F
	GoRXSMtWiSfWNAu1CAGto/vKkYfEy6sX2STVk6xg/0L+qJm5ZA38os2TK8RmvW9qF0w==
X-Received: by 2002:a63:607:: with SMTP id 7mr14747700pgg.240.1565305596066;
        Thu, 08 Aug 2019 16:06:36 -0700 (PDT)
X-Received: by 2002:a63:607:: with SMTP id 7mr14747648pgg.240.1565305595189;
        Thu, 08 Aug 2019 16:06:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565305595; cv=none;
        d=google.com; s=arc-20160816;
        b=oM7yYQWoERzq3Xm26VZP/lVgBVOPZSY79kk9M7TwCQNFD5Hvp2pT25dfzCO3iv/luU
         rXJ/Gghmln6KzXCk9yEitfOB5K0cPperjs0cwdpt7Vc7r6FhPT1B2h48O6QFqr+BLEpZ
         zFqFEM7HOLZQpqKG6paikbmdmca833ok5jx8Mmk7i9OHOawtxgnLoLuaRYdaqfrzq5HA
         w00JCE7xkrjiZnls4f4bvIFXD3Ztdw9F5jsSW1tPZbqeN0U9MckzPhe5ybqVXoPYWi8n
         0Sk6WJ4KsZ7jpzi8AC+xPoh+p9YJgeThV27tBBSwdvINvG2zSoFENeNS+kDPmqqLzzSF
         Y0Wg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=opDMrymB/En0zVOQAsZzeK0WBnbwyQ7DVo+LI/G+0nI=;
        b=frfLQRUMsXdfYq29sG8Uazy0Er5ReIUBD1twvxXAK14AdXhFpdOojm1wsqhZ1MdlB9
         29mjtczodlWqecjep/BOVG146kjoSd0ObnMWscB6b1IwLavE8Sv8MpiuWtVZtFp2CcZV
         6ze1eoko8RROWDqGRFbuF+hkH1w1fHkBeos4/X9gXg0355Gqi/0DTqNsab3vtwohOsgC
         gREoEwuyPhwHPg6iqCqrXj872IEMt+ljU+cA/5oLS7ZQeaakYJHATfjArrnJciZJfJ7A
         cngX70U7RYI9Jxde3+0CprbLkiIWTJKpbDdZaijnpiOwmeNe9fCQxI84Vwyp/px3/ptb
         8ybA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=ikTsZpqI;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r9sor17779138pgj.41.2019.08.08.16.06.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 08 Aug 2019 16:06:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=ikTsZpqI;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=opDMrymB/En0zVOQAsZzeK0WBnbwyQ7DVo+LI/G+0nI=;
        b=ikTsZpqIALXHfXNNPn5q3xwkHzwN31/cjFf8yGaawKBFYr5bEoqwkcLNwNqmnBP3dA
         lyew0kxGzn/wvTC0S6ZqPLMDZ0NxIAWDt+Z8QguV81Gm7yLFJ6Q233iY3boexCsjZoN2
         3Y+CaPJoubQgDiCyBanDym6GLAfqcLDCeDv7M=
X-Google-Smtp-Source: APXvYqxUs/ShSH3NodCVNupDwfPt/CTgZNHs1MZIiS1TQWwVh5q0LUSuD7/p4QawSHP4cg3vnLnTUw==
X-Received: by 2002:a63:61cd:: with SMTP id v196mr15062795pgb.263.1565305594747;
        Thu, 08 Aug 2019 16:06:34 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id p3sm267596pjo.3.2019.08.08.16.06.33
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 08 Aug 2019 16:06:33 -0700 (PDT)
Date: Thu, 8 Aug 2019 16:06:32 -0700
From: Kees Cook <keescook@chromium.org>
To: Greg KH <gregkh@linuxfoundation.org>
Cc: syzbot <syzbot+45b2f40f0778cfa7634e@syzkaller.appspotmail.com>,
	Michael Hund <mhund@ld-didactic.de>, akpm@linux-foundation.org,
	andreyknvl@google.com, cai@lca.pw, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, linux-usb@vger.kernel.org,
	syzkaller-bugs@googlegroups.com, tglx@linutronix.de
Subject: Re: BUG: bad usercopy in ld_usb_read
Message-ID: <201908081604.D1203D408@keescook>
References: <0000000000005c056c058f9a5437@google.com>
 <20190808124654.GB32144@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190808124654.GB32144@kroah.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 08, 2019 at 02:46:54PM +0200, Greg KH wrote:
> On Thu, Aug 08, 2019 at 05:38:06AM -0700, syzbot wrote:
> > Hello,
> > 
> > syzbot found the following crash on:
> > 
> > HEAD commit:    e96407b4 usb-fuzzer: main usb gadget fuzzer driver
> > git tree:       https://github.com/google/kasan.git usb-fuzzer
> > console output: https://syzkaller.appspot.com/x/log.txt?x=13aeaece600000
> > kernel config:  https://syzkaller.appspot.com/x/.config?x=cfa2c18fb6a8068e
> > dashboard link: https://syzkaller.appspot.com/bug?extid=45b2f40f0778cfa7634e
> > compiler:       gcc (GCC) 9.0.0 20181231 (experimental)
> > 
> > Unfortunately, I don't have any reproducer for this crash yet.
> > 
> > IMPORTANT: if you fix the bug, please add the following tag to the commit:
> > Reported-by: syzbot+45b2f40f0778cfa7634e@syzkaller.appspotmail.com
> > 
> > ldusb 6-1:0.124: Read buffer overflow, -131383996186150 bytes dropped
> 
> That's a funny number :)
> 
> Nice overflow found, I see you are now starting to fuzz the char device
> nodes of usb drivers...
> 
> Michael, care to fix this up?

This looks like the length in the read-from-device buffer is unchecked:

        /* actual_buffer contains actual_length + interrupt_in_buffer */
        actual_buffer = (size_t *)(dev->ring_buffer + dev->ring_tail * (sizeof(size_t)+dev->interrupt_in_endpoint_size));
        bytes_to_read = min(count, *actual_buffer);
        if (bytes_to_read < *actual_buffer)
                dev_warn(&dev->intf->dev, "Read buffer overflow, %zd bytes dropped\n",
                         *actual_buffer-bytes_to_read);

        /* copy one interrupt_in_buffer from ring_buffer into userspace */
        if (copy_to_user(buffer, actual_buffer+1, bytes_to_read)) {
                retval = -EFAULT;
                goto unlock_exit;
        }

I assume what's stored at actual_buffer is bogus and needs validation
somewhere before it's actually used. (If not here, maybe where ever the
write into the buffer originally happens?)

-- 
Kees Cook


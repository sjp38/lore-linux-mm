Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 44BFFC0650F
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 20:42:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EBD9C21743
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 20:42:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="TsthMIhq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EBD9C21743
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8B2A66B000A; Thu,  8 Aug 2019 16:42:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8627C6B000C; Thu,  8 Aug 2019 16:42:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 750AF6B000D; Thu,  8 Aug 2019 16:42:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3B1EA6B000A
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 16:42:03 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id x10so158734pfn.2
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 13:42:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=nS7CPtzCVp0ONgQlGgkx7OXPZavZodPDNiD74pSN4ok=;
        b=JSqNC0qQ3cin5l4YEM8OA9v4COWDeCbMGWZSEMGCOfdMChHLMFdsMqdxrj8x/AjIn9
         WIwzCxohvcizb3njAmv7Hh2ELmE7WzXPVHit2bU6Guzw3UVPCK396wMc4Cag4r0nfuCU
         G5+3KjHkBgltFgUt9DAoMgSEE5MUSdHk84I5MSOkVNQBBxaa9GE2PiVqwNPUiYnlDSSk
         2gTGk5arlELyLNiNkpVm95WqYfJtJuF7uzTdmOe2RvRnu9YV5i4jeAUG8BkbbprZq0Bt
         XOUiXEmeDdhZnDvFmCzd0lUXKQuP/gP4nykXMF/EOthLMS4y1iZBc+XZnQX6peOIQnAQ
         Slkg==
X-Gm-Message-State: APjAAAWAd6NtDkJBmphEcJFU/OxD4FjTlIGf5d6HAoIG60uLdRjPr/jC
	qjd+dQF0rEhMBOzdoiYmZQ3Sbj6OAbDKvW8d3Fedne7yNMXIyyjacuUW71E84prQ9RYQRf0Cm9I
	AhV3AgLEYvZysP8Df/6JmSecqHYqNlbOSHfxYoqldUGxhut4j6kAYuH3NwSLY+IzhDg==
X-Received: by 2002:a62:e806:: with SMTP id c6mr17682266pfi.158.1565296922814;
        Thu, 08 Aug 2019 13:42:02 -0700 (PDT)
X-Received: by 2002:a62:e806:: with SMTP id c6mr17682210pfi.158.1565296922009;
        Thu, 08 Aug 2019 13:42:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565296922; cv=none;
        d=google.com; s=arc-20160816;
        b=U7c7ZlEQcGvi3xyoIQviYVFD+LPLnGVyXze6Rr3FfQrFDONLCMmO0rC8aIZRBQGdc7
         ve1qokdA82ODwy/RVGkoQKiQgZzXU6vgYxsmU5TdVqaUJpgpvDmndAU5t3OtLb77gSEG
         UGh07AFCsAyptxp4gBCVya9XQFOT25NhDfZDxlZMH7LiIn6tfKILAqEFyoVa7pkUEUWe
         q3SXXkblOTLmg9GqEASosF2bGtIIeXoupipdvr4NWWKF900HL2h/LypoWvbI1dncDrbX
         ZHgE9dKqv5mI+5HTkci1vZ+rkn5vWXBDx7VAWehtrcWs/w/GAITi79UM/oPiDCzonzxn
         weOQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=nS7CPtzCVp0ONgQlGgkx7OXPZavZodPDNiD74pSN4ok=;
        b=cW+so3Bx9mmx43EIBoLzdVzssSODTJaQCaWprQfdNn+ISTjp5BEub6Gpjy3fmgC+LW
         di5ICisQHfF6VNNfG0yVDDmM68KvJcMK/q0ERXVX0XlgIYNnUHFlyhp+sqGIvVJ4nBND
         lrtBMLTqpU2aev095Q7W0G600qS52muhfcO/vJ5wOxXLSrB/A3FD2yqoLDhSEVcTM8sN
         R+zz+5fdLDPmkb6ZqRlKdVcL2GdpvIWorKTQucltXeE5zMOfk/+yRAkF+aaWbM69OnIF
         EA5I3lFf+K+vQI6zM5zJ+e+4wMAp8jMZ2Q2gjOxBAFRHT4UWBSjRm1X394CgFTqQTKno
         wkmQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=TsthMIhq;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h71sor67396598pge.80.2019.08.08.13.42.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 08 Aug 2019 13:42:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=TsthMIhq;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=nS7CPtzCVp0ONgQlGgkx7OXPZavZodPDNiD74pSN4ok=;
        b=TsthMIhqXtbXp4xH+Z2wSZTAZqhudiQe7esQYSq3NqIJCExnewze/88rqQMCne0v0d
         FN5dRFOqevBvVNOO8AUZEPv3dAUQomTJ83wd9Wr7Y+kJNgX0HKAZzjJBQBi18lQPhP3w
         ASwqJ7VwHaeLqfgYDU479i5gbC/Pz/daiarWM=
X-Google-Smtp-Source: APXvYqzXHxnpRFvH9kCf1Uy9J4cWLZwuOKZTZDqgdkWhjibPvjL0xvjuHKfltUtrW/23JO7iytrk3Q==
X-Received: by 2002:a63:60d1:: with SMTP id u200mr14395334pgb.439.1565296921533;
        Thu, 08 Aug 2019 13:42:01 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id s22sm103042884pfh.107.2019.08.08.13.42.00
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 08 Aug 2019 13:42:00 -0700 (PDT)
Date: Thu, 8 Aug 2019 13:41:59 -0700
From: Kees Cook <keescook@chromium.org>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: Matthew Wilcox <willy@infradead.org>,
	syzbot <syzbot+3de312463756f656b47d@syzkaller.appspotmail.com>,
	allison@lohutok.net, andreyknvl@google.com, cai@lca.pw,
	gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, linux-usb@vger.kernel.org,
	syzkaller-bugs@googlegroups.com, tglx@linutronix.de,
	Jiri Kosina <jkosina@suse.cz>
Subject: Re: BUG: bad usercopy in hidraw_ioctl
Message-ID: <201908081330.98485D9@keescook>
References: <000000000000ce6527058f8bf0d0@google.com>
 <20190807195821.GD5482@bombadil.infradead.org>
 <20190808014925.GL1131@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190808014925.GL1131@ZenIV.linux.org.uk>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 08, 2019 at 02:49:25AM +0100, Al Viro wrote:
> On Wed, Aug 07, 2019 at 12:58:21PM -0700, Matthew Wilcox wrote:
> > On Wed, Aug 07, 2019 at 12:28:06PM -0700, syzbot wrote:
> > > usercopy: Kernel memory exposure attempt detected from wrapped address
> > > (offset 0, size 0)!
> > > ------------[ cut here ]------------
> > > kernel BUG at mm/usercopy.c:98!
> > 
> > This report is confusing because the arguments to usercopy_abort() are wrong.
> > 
> >         /* Reject if object wraps past end of memory. */
> >         if (ptr + n < ptr)
> >                 usercopy_abort("wrapped address", NULL, to_user, 0, ptr + n);

(Just to reiterate for this branch of the thread: this is an off-by-one
false positive already fixed in -mm for -next. However, see below...)

> > 
> > ptr + n is not 'size', it's what wrapped.  I don't know what 'offset'
> > should be set to, but 'size' should be 'n'.  Presumably we don't want to
> > report 'ptr' because it'll leak a kernel address ... reporting 'n' will
> > leak a range for a kernel address, but I think that's OK?  Admittedly an
> > attacker can pass in various values for 'n', but it'll be quite noisy
> > and leave a trace in the kernel logs for forensics to find afterwards.
> > 
> > > Call Trace:
> > >  check_bogus_address mm/usercopy.c:151 [inline]
> > >  __check_object_size mm/usercopy.c:260 [inline]
> > >  __check_object_size.cold+0xb2/0xba mm/usercopy.c:250
> > >  check_object_size include/linux/thread_info.h:119 [inline]
> > >  check_copy_size include/linux/thread_info.h:150 [inline]
> > >  copy_to_user include/linux/uaccess.h:151 [inline]
> > >  hidraw_ioctl+0x38c/0xae0 drivers/hid/hidraw.c:392
> > 
> > The root problem would appear to be:
> > 
> >                                 else if (copy_to_user(user_arg + offsetof(
> >                                         struct hidraw_report_descriptor,
> >                                         value[0]),
> >                                         dev->hid->rdesc,
> >                                         min(dev->hid->rsize, len)))
> > 
> > That 'min' should surely be a 'max'?
> 
> Surely not.  ->rsize is the amount of data available to copy out; len
> is the size of buffer supplied by userland to copy into.

include/uapi/linux/hid.h:#define HID_MAX_DESCRIPTOR_SIZE 4096

drivers/hid/hidraw.c:
                        if (get_user(len, (int __user *)arg))
                                ret = -EFAULT;
                        else if (len > HID_MAX_DESCRIPTOR_SIZE - 1)
                                ret = -EINVAL;
                        else if (copy_to_user(user_arg + offsetof(
                                struct hidraw_report_descriptor,
                                value[0]),
                                dev->hid->rdesc,
                                min(dev->hid->rsize, len)))
                                ret = -EFAULT;

The copy size must be less than 4096, which means dev->hid->rdesc is
allocated at the highest page of memory. That whole space collides with
the ERR_PTR region which has two bad potential side-effects:

1) something that checks for ERR_PTRs combined with a high allocation
will think it failed and leak the allocation.

2) something that doesn't check ERR_PTRs might try to stomp on an actual
allocation in that area.

How/why is there memory allocated there, I thought it was intentionally
left unused specifically for ERR_PTR:

Documentation/x86/x86_64/mm.rst:

     Start addr    | Offset |     End addr     | Size  | VM area description
  ==========================================================================
  ...
  ffffffffffe00000 | -2  MB | ffffffffffffffff |  2 MB | ...unused hole


or is this still a real bug with an invalid dev->hid->rdesc which was
about to fault but usercopy got in the way first?

-- 
Kees Cook


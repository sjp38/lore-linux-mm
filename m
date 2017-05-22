Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id C2D05831F4
	for <linux-mm@kvack.org>; Mon, 22 May 2017 15:46:50 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id h4so172235670oib.5
        for <linux-mm@kvack.org>; Mon, 22 May 2017 12:46:50 -0700 (PDT)
Received: from lhrrgout.huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id t28si7657874ote.328.2017.05.22.12.46.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 22 May 2017 12:46:50 -0700 (PDT)
Subject: Re: [kernel-hardening] [PATCH 1/1] Sealable memory support
References: <20170519103811.2183-1-igor.stoppa@huawei.com>
 <20170519103811.2183-2-igor.stoppa@huawei.com>
 <20170520085147.GA4619@kroah.com>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <b3b4a71a-01a4-dad2-8df4-8b945c25be2f@huawei.com>
Date: Mon, 22 May 2017 22:45:26 +0300
MIME-Version: 1.0
In-Reply-To: <20170520085147.GA4619@kroah.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <gregkh@linuxfoundation.org>
Cc: mhocko@kernel.org, dave.hansen@intel.com, labbott@redhat.com, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, linux-kernel@vger.kernel.org

On 20/05/17 11:51, Greg KH wrote:
> On Fri, May 19, 2017 at 01:38:11PM +0300, Igor Stoppa wrote:
>> Dynamically allocated variables can be made read only,

[...]

> This is really nice, do you have a follow-on patch showing how any of
> the kernel can be changed to use this new subsystem?

Yes, actually I started from the need of turning into R/O some data
structures in both LSM Hooks and SE Linux.

> Without that, it
> might be hard to get this approved (we don't like adding new apis
> without users.)

Yes, I just wanted to give an early preview of the current
implementation, since it is significantly different from what I
initially proposed. So I was looking for early feedback.

Right now, I'm fixing it up and adding some more structured debugging.

Then I'll re-submit it together with the LSM Hooks example.

---
thanks, igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f172.google.com (mail-ob0-f172.google.com [209.85.214.172])
	by kanga.kvack.org (Postfix) with ESMTP id 224576B0253
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 17:03:24 -0400 (EDT)
Received: by mail-ob0-f172.google.com with SMTP id tz8so34229942obc.0
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 14:03:24 -0700 (PDT)
Received: from mail-oi0-x22d.google.com (mail-oi0-x22d.google.com. [2607:f8b0:4003:c06::22d])
        by mx.google.com with ESMTPS id n31si1637404otb.93.2016.04.06.14.03.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Apr 2016 14:03:23 -0700 (PDT)
Received: by mail-oi0-x22d.google.com with SMTP id y204so74217476oie.3
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 14:03:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160406205429.GA13901@kroah.com>
References: <1459971348-81477-1-git-send-email-thgarnie@google.com>
	<20160406205429.GA13901@kroah.com>
Date: Wed, 6 Apr 2016 14:03:22 -0700
Message-ID: <CAJcbSZFs3wJ3hEkvWoLH-9h+Dk_mTCfRUnH7o1JvcS-5AGY3kQ@mail.gmail.com>
Subject: Re: [kernel-hardening] [RFC v1] mm: SLAB freelist randomization
From: Thomas Garnier <thgarnie@google.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <gregkh@linuxfoundation.org>
Cc: kernel-hardening@lists.openwall.com, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, labbott@fedoraproject.org

Yes, sorry about that. It will be in the next RFC or PATCH.

On Wed, Apr 6, 2016 at 1:54 PM, Greg KH <gregkh@linuxfoundation.org> wrote:
> On Wed, Apr 06, 2016 at 12:35:48PM -0700, Thomas Garnier wrote:
>> Provide an optional config (CONFIG_FREELIST_RANDOM) to randomize the
>> SLAB freelist. This security feature reduces the predictability of
>> the kernel slab allocator against heap overflows.
>>
>> Randomized lists are pre-computed using a Fisher-Yates shuffle and
>> re-used on slab creation for performance.
>> ---
>> Based on next-20160405
>> ---
>
> No signed-off-by:?
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

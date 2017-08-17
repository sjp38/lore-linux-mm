Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id A9AC16B02B4
	for <linux-mm@kvack.org>; Thu, 17 Aug 2017 16:57:11 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id k62so9945704oia.6
        for <linux-mm@kvack.org>; Thu, 17 Aug 2017 13:57:11 -0700 (PDT)
Received: from mail-io0-x244.google.com (mail-io0-x244.google.com. [2607:f8b0:4001:c06::244])
        by mx.google.com with ESMTPS id s63si3232183oie.244.2017.08.17.13.57.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Aug 2017 13:57:09 -0700 (PDT)
Received: by mail-io0-x244.google.com with SMTP id c74so4651709iod.4
        for <linux-mm@kvack.org>; Thu, 17 Aug 2017 13:57:09 -0700 (PDT)
Message-ID: <1503003427.1514.6.camel@gmail.com>
Subject: Re: [PATCHv3 2/2] extract early boot entropy from the passed cmdline
From: Daniel Micay <danielmicay@gmail.com>
Date: Thu, 17 Aug 2017 16:57:07 -0400
In-Reply-To: <1502943802.3986.38.camel@gmail.com>
References: <20170816231458.2299-1-labbott@redhat.com>
	 <20170816231458.2299-3-labbott@redhat.com>
	 <20170817033148.ownsmbdzk2vhupme@thunk.org>
	 <1502943802.3986.38.camel@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Laura Abbott <labbott@redhat.com>
Cc: Kees Cook <keescook@chromium.org>, kernel-hardening@lists.openwall.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

> I did say 'external attacker' but it could be made clearer.

Er, s/say/mean to imply/

I do think it will have some local value after Android 8 which should
start shipping in a few days though.

I'll look into having the kernel stash some entropy in pstore soon since
that seems like it could be a great improvement. I'm not sure how often
/ where it should hook into for regularly refreshing it though. Doing it
only on powering down isn't ideal.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

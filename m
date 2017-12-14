Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id C6FF46B0033
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 05:09:46 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id w7so4312714pfd.4
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 02:09:46 -0800 (PST)
Received: from BJEXCAS003.didichuxing.com ([36.110.17.22])
        by mx.google.com with ESMTPS id j6si2699205pgq.184.2017.12.14.02.09.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 14 Dec 2017 02:09:45 -0800 (PST)
Date: Thu, 14 Dec 2017 18:09:27 +0800
From: weiping zhang <zhangweiping@didichuxing.com>
Subject: Re: Regression with a0747a859ef6 ("bdi: add error handle for
 bdi_debug_register")
Message-ID: <20171214100927.GA26167@localhost.didichuxing.com>
References: <b1415a6d-fccd-31d0-ffa2-9b54fa699692@redhat.com>
 <20171214082452.GA16698@wolff.to>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20171214082452.GA16698@wolff.to>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bruno Wolff III <bruno@wolff.to>
Cc: Laura Abbott <labbott@redhat.com>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, regressions@leemhuis.info, linux-block@vger.kernel.org

On Thu, Dec 14, 2017 at 02:24:52AM -0600, Bruno Wolff III wrote:
> On Wed, Dec 13, 2017 at 16:54:17 -0800,
>  Laura Abbott <labbott@redhat.com> wrote:
> >Hi,
> >
> >Fedora got a bug report https://bugzilla.redhat.com/show_bug.cgi?id=1520982
> >of a boot failure/bug on Linus' master (full bootlog at the bugzilla)
> 
> I'm available for testing. The problem happens on my x86_64 Dell
> Workstation, but not an old i386 server or an x86_64 mac hardware
> based laptop.

Hi,

It seems something wrong with bdi debugfs register, could you help
test the forllowing debug patch, I add some debug log, no function
change, thanks.

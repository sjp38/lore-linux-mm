Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 08A096B0033
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 03:27:53 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id a3so7116987itg.7
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 00:27:53 -0800 (PST)
Received: from wolff.to (wolff.to. [98.103.208.27])
        by mx.google.com with SMTP id o17si2768617ita.69.2017.12.14.00.27.51
        for <linux-mm@kvack.org>;
        Thu, 14 Dec 2017 00:27:51 -0800 (PST)
Date: Thu, 14 Dec 2017 02:24:52 -0600
From: Bruno Wolff III <bruno@wolff.to>
Subject: Re: Regression with a0747a859ef6 ("bdi: add error handle for
 bdi_debug_register")
Message-ID: <20171214082452.GA16698@wolff.to>
References: <b1415a6d-fccd-31d0-ffa2-9b54fa699692@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <b1415a6d-fccd-31d0-ffa2-9b54fa699692@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, regressions@leemhuis.info, weiping zhang <zhangweiping@didichuxing.com>, linux-block@vger.kernel.org

On Wed, Dec 13, 2017 at 16:54:17 -0800,
  Laura Abbott <labbott@redhat.com> wrote:
>Hi,
>
>Fedora got a bug report https://bugzilla.redhat.com/show_bug.cgi?id=1520982
>of a boot failure/bug on Linus' master (full bootlog at the bugzilla)

I'm available for testing. The problem happens on my x86_64 Dell Workstation, 
but not an old i386 server or an x86_64 mac hardware based laptop.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

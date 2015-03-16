Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id E3DF56B0032
	for <linux-mm@kvack.org>; Mon, 16 Mar 2015 10:50:26 -0400 (EDT)
Received: by wixw10 with SMTP id w10so31495883wix.0
        for <linux-mm@kvack.org>; Mon, 16 Mar 2015 07:50:26 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c13si16546906wik.53.2015.03.16.07.50.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 16 Mar 2015 07:50:25 -0700 (PDT)
Message-ID: <1426517419.28068.118.camel@stgolabs.net>
Subject: Re: [PATCH] mm: rcu-protected get_mm_exe_file()
From: Davidlohr Bueso <dave@stgolabs.net>
Date: Mon, 16 Mar 2015 07:50:19 -0700
In-Reply-To: <20150316140720.GA1859@redhat.com>
References: <20150316131257.32340.36600.stgit@buzz>
	 <20150316140720.GA1859@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>

On Mon, 2015-03-16 at 15:07 +0100, Oleg Nesterov wrote:
> 	3. and we can remove down_write(mmap_sem) from prctl paths.
> 
> 	   Actually we can do this even without xchg() above, but we might
> 	   want to kill MMF_EXE_FILE_CHANGED and test_and_set_bit() check.

Yeah I was waiting for security folks input about this, otherwise this
still doesn't do it for me as we still have to deal with mmap_sem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

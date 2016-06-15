Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7D6AD6B007E
	for <linux-mm@kvack.org>; Wed, 15 Jun 2016 18:44:04 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id g62so71252063pfb.3
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 15:44:04 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id a74si1722414pfa.164.2016.06.15.15.44.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jun 2016 15:44:03 -0700 (PDT)
Date: Wed, 15 Jun 2016 15:44:02 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [mel:mm-vmscan-node-lru-v7r3 38/200] slub.c:undefined reference
 to `cache_random_seq_create'
Message-Id: <20160615154402.d903d57a64377df7ebc77ad9@linux-foundation.org>
In-Reply-To: <CAGXu5jLKS=cWJJozFOYyjzNuiBt5GTSBAfZCyFRXh3oVE5QE=g@mail.gmail.com>
References: <201606140353.WeDaHl1M%fengguang.wu@intel.com>
	<20160613141123.fcb245b6a7fd3199ae8a32d7@linux-foundation.org>
	<CAGXu5jLH+UzOhPfj5VkydHg=ZxbrQHQe6C1C-dbCBzsAmW9M2Q@mail.gmail.com>
	<CAGXu5jJ-ga0pXVtkCFSS6tGnsuhhNxOOguexUU14_4fwa3Uaeg@mail.gmail.com>
	<20160615142628.75bf404e7b48e239759f6994@linux-foundation.org>
	<CAGXu5jLKS=cWJJozFOYyjzNuiBt5GTSBAfZCyFRXh3oVE5QE=g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: kbuild test robot <fengguang.wu@intel.com>, kbuild-all@01.org, Mel Gorman <mgorman@suse.de>, Thomas Garnier <thgarnie@google.com>, Linux Memory Management List <linux-mm@kvack.org>

On Wed, 15 Jun 2016 15:37:48 -0700 Kees Cook <keescook@chromium.org> wrote:

> (Did your gcc-4.4.4 ever build with CONFIG_CC_STACKPROTECTOR enabled?)

I doubt it.  With this compiler I usually just do allmodconfig and
let it rip.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

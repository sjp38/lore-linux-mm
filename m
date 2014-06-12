Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f43.google.com (mail-pb0-f43.google.com [209.85.160.43])
	by kanga.kvack.org (Postfix) with ESMTP id 0E6A26B00EE
	for <linux-mm@kvack.org>; Thu, 12 Jun 2014 09:27:06 -0400 (EDT)
Received: by mail-pb0-f43.google.com with SMTP id up15so1002931pbc.16
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 06:27:06 -0700 (PDT)
Received: from mail-pd0-x22b.google.com (mail-pd0-x22b.google.com [2607:f8b0:400e:c02::22b])
        by mx.google.com with ESMTPS id vq10si1115036pab.121.2014.06.12.06.27.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 12 Jun 2014 06:27:06 -0700 (PDT)
Received: by mail-pd0-f171.google.com with SMTP id ft15so970477pdb.2
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 06:27:05 -0700 (PDT)
Message-ID: <1402579513.1106.13.camel@debian>
Subject: Re: [PATCH] mm/vmscan.c: wrap five parameters into arg_container
 in shrink_page_list()
From: Chen Yucong <slaoub@gmail.com>
In-Reply-To: <5399A0F3.8040106@redhat.com>
References: <1402565795-706-1-git-send-email-slaoub@gmail.com>
	 <5399A0F3.8040106@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 12 Jun 2014 21:25:13 +0800
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: akpm@linux-foundation.org, mgorman@suse.de, hannes@cmpxchg.org, mhocko@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 2014-06-12 at 08:45 -0400, Rik van Riel wrote:
> > shrink_page_list() has too many arguments that have already reached
> ten.
> > Some of those arguments and temporary variables introduces extra 80
> bytes
> > on the stack.
> > 
> > This patch wraps five parameters into arg_container and removes some
> temporary
> > variables, thus making shrink_page_list() to consume fewer stack
> space.
> 
> Won't the container with those arguments now live on the stack,
> using up the same space that the variables used to take?
> 
Of course, the container with those arguments live on the stack.

One of the key reason for introducing this patch is to avoid passing
five pointer arguments to shrink_page_list().

The arg_container also uses up the same space that the variables used to
take.
If the those arguments is wrapped to arg_container, we just need to pass
one pointer to shrink_page_list instead of five.

thx!
cyc  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

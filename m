Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id AA7896B00C5
	for <linux-mm@kvack.org>; Fri, 13 Jun 2014 09:49:26 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id fp1so2155718pdb.38
        for <linux-mm@kvack.org>; Fri, 13 Jun 2014 06:49:26 -0700 (PDT)
Received: from mail-pb0-x22a.google.com (mail-pb0-x22a.google.com [2607:f8b0:400e:c01::22a])
        by mx.google.com with ESMTPS id ct4si2215421pbb.189.2014.06.13.06.49.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 13 Jun 2014 06:49:25 -0700 (PDT)
Received: by mail-pb0-f42.google.com with SMTP id ma3so1916053pbc.29
        for <linux-mm@kvack.org>; Fri, 13 Jun 2014 06:49:25 -0700 (PDT)
Message-ID: <1402667259.6072.20.camel@debian>
Subject: Re: [RESEND PATCH v2] mm/vmscan.c: wrap five parameters into
 writeback_stats for reducing the stack consumption
From: Chen Yucong <slaoub@gmail.com>
In-Reply-To: <1402639088-4845-1-git-send-email-slaoub@gmail.com>
References: <1402639088-4845-1-git-send-email-slaoub@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 13 Jun 2014 21:47:39 +0800
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mgorman@suse.de, hannes@cmpxchg.org, mhocko@suse.cz, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi all,

On Fri, 2014-06-13 at 13:58 +0800, Chen Yucong wrote:
> shrink_page_list() has too many arguments that have already reached ten.
> Some of those arguments and temporary variables introduces extra 80 bytes
> on the stack. This patch wraps five parameters into writeback_stats and removes
> some temporary variables, thus making the relative functions to consume fewer
> stack space.
> 
I this message, I have renamed shrink_result to writeback_stats
according to Johannes Weiner's reply. Think carefully, this change is
too hasty. Although it now just contains statistics on the writeback
states of the scanned pages, it may also be used for gathering other
information at some point in the future. So I think shrink_result is a
little bit better!

thx!
cyc


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

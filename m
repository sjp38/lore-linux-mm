Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f54.google.com (mail-qa0-f54.google.com [209.85.216.54])
	by kanga.kvack.org (Postfix) with ESMTP id E3E5E6B0071
	for <linux-mm@kvack.org>; Thu, 15 Jan 2015 14:08:44 -0500 (EST)
Received: by mail-qa0-f54.google.com with SMTP id w8so11630634qac.13
        for <linux-mm@kvack.org>; Thu, 15 Jan 2015 11:08:44 -0800 (PST)
Received: from mail-qg0-x229.google.com (mail-qg0-x229.google.com. [2607:f8b0:400d:c04::229])
        by mx.google.com with ESMTPS id n52si3035079qge.91.2015.01.15.11.08.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 15 Jan 2015 11:08:43 -0800 (PST)
Received: by mail-qg0-f41.google.com with SMTP id e89so13187864qgf.0
        for <linux-mm@kvack.org>; Thu, 15 Jan 2015 11:08:43 -0800 (PST)
Date: Thu, 15 Jan 2015 14:08:40 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 3/6] memcg: track shared inodes with dirty pages
Message-ID: <20150115190840.GD28195@htj.dyndns.org>
References: <20150115180242.10450.92.stgit@buzz>
 <20150115184914.10450.51964.stgit@buzz>
 <20150115185543.GA28195@htj.dyndns.org>
 <CALYGNiPY2K6F+OFoCV5XShrXaQOiyGXreR=4TC=Mp7axTiF0YQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALYGNiPY2K6F+OFoCV5XShrXaQOiyGXreR=4TC=Mp7axTiF0YQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Konstantin Khebnikov <khlebnikov@yandex-team.ru>, "linux-mm@kvack.org" <linux-mm@kvack.org>, cgroups@vger.kernel.org, Roman Gushchin <klamm@yandex-team.ru>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

Hello,

On Thu, Jan 15, 2015 at 11:04:49PM +0400, Konstantin Khlebnikov wrote:
> I know. Absolutely accurate per-page solution looks too complicated for me.
> Is there any real demand for accurate handling dirty set in shared inodes?
> Doing whole accounting in per-inode basis makes life so much easier.

Ah, yeah, patch #3 arrived in isolation, so I thought it was part of
something completely different.  I definitely thought about doing it
per-inode too (and also requiring memcg to attribute pages according
to its inode rather than individual pages).  I'll look into the
patchset and try to identify the pros and cons of our approaches.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

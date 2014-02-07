Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id D1A3A6B0036
	for <linux-mm@kvack.org>; Fri,  7 Feb 2014 15:48:01 -0500 (EST)
Received: by mail-pd0-f173.google.com with SMTP id y10so3601027pdj.18
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 12:48:01 -0800 (PST)
Received: from mail-pd0-x231.google.com (mail-pd0-x231.google.com [2607:f8b0:400e:c02::231])
        by mx.google.com with ESMTPS id ui8si6316861pac.177.2014.02.07.12.48.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 07 Feb 2014 12:48:00 -0800 (PST)
Received: by mail-pd0-f177.google.com with SMTP id x10so3606600pdj.36
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 12:48:00 -0800 (PST)
Date: Fri, 7 Feb 2014 12:47:58 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 3/9] mm: Mark function as static in mmap.c
In-Reply-To: <a2b21fa8852f0ee5c8da179240142e5f084154e9.1391167128.git.rashika.kheria@gmail.com>
Message-ID: <alpine.DEB.2.02.1402071247470.4212@chino.kir.corp.google.com>
References: <a7658fc8f2ab015bffe83de1448cc3db79d2a9fc.1391167128.git.rashika.kheria@gmail.com> <a2b21fa8852f0ee5c8da179240142e5f084154e9.1391167128.git.rashika.kheria@gmail.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="531381512-2106216631-1391806079=:4212"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rashika Kheria <rashika.kheria@gmail.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>, Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org, josh@joshtriplett.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--531381512-2106216631-1391806079=:4212
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT

On Fri, 7 Feb 2014, Rashika Kheria wrote:

> Mark function as static in mmap.c because they are not used outside this
> file.
> 
> This eliminates the following warning in mm/mmap.c:
> mm/mmap.c:407:6: warning: no previous prototype for a??validate_mma?? [-Wmissing-prototypes]
> 
> Signed-off-by: Rashika Kheria <rashika.kheria@gmail.com>
> Reviewed-by: Josh Triplett <josh@joshtriplett.org>

Acked-by: David Rientjes <rientjes@google.com>
--531381512-2106216631-1391806079=:4212--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

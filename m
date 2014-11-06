Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f180.google.com (mail-ie0-f180.google.com [209.85.223.180])
	by kanga.kvack.org (Postfix) with ESMTP id E22866B00CD
	for <linux-mm@kvack.org>; Thu,  6 Nov 2014 16:59:25 -0500 (EST)
Received: by mail-ie0-f180.google.com with SMTP id y20so3997244ier.11
        for <linux-mm@kvack.org>; Thu, 06 Nov 2014 13:59:25 -0800 (PST)
Received: from mail-ig0-x229.google.com (mail-ig0-x229.google.com. [2607:f8b0:4001:c05::229])
        by mx.google.com with ESMTPS id qo6si12204298igb.30.2014.11.06.13.59.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 06 Nov 2014 13:59:24 -0800 (PST)
Received: by mail-ig0-f169.google.com with SMTP id hn18so11026117igb.4
        for <linux-mm@kvack.org>; Thu, 06 Nov 2014 13:59:24 -0800 (PST)
Date: Thu, 6 Nov 2014 13:59:22 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2] mm: slub: fix format mismatches in slab_err()
 callers
In-Reply-To: <1415261817-5283-1-git-send-email-a.ryabinin@samsung.com>
Message-ID: <alpine.DEB.2.10.1411061359060.1526@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1411051344490.31575@chino.kir.corp.google.com> <1415261817-5283-1-git-send-email-a.ryabinin@samsung.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="531381512-1184225831-1415311163=:1526"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--531381512-1184225831-1415311163=:1526
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT

On Thu, 6 Nov 2014, Andrey Ryabinin wrote:

> Adding __printf(3, 4) to slab_err exposed following:
> 
> mm/slub.c: In function a??check_slaba??:
> mm/slub.c:852:4: warning: format a??%ua?? expects argument of type a??unsigned inta??, but argument 4 has type a??const char *a?? [-Wformat=]
>     s->name, page->objects, maxobj);
>     ^
> mm/slub.c:852:4: warning: too many arguments for format [-Wformat-extra-args]
> mm/slub.c:857:4: warning: format a??%ua?? expects argument of type a??unsigned inta??, but argument 4 has type a??const char *a?? [-Wformat=]
>     s->name, page->inuse, page->objects);
>     ^
> mm/slub.c:857:4: warning: too many arguments for format [-Wformat-extra-args]
> 
> mm/slub.c: In function a??on_freelista??:
> mm/slub.c:905:4: warning: format a??%da?? expects argument of type a??inta??, but argument 5 has type a??long unsigned inta?? [-Wformat=]
>     "should be %d", page->objects, max_objects);
> 
> Fix first two warnings by removing redundant s->name.
> Fix the last by changing type of max_object from unsigned long to int.
> 
> Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Pekka Enberg <penberg@kernel.org>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Acked-by: David Rientjes <rientjes@google.com>
--531381512-1184225831-1415311163=:1526--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

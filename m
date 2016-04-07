Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f174.google.com (mail-qk0-f174.google.com [209.85.220.174])
	by kanga.kvack.org (Postfix) with ESMTP id B3AD86B0005
	for <linux-mm@kvack.org>; Thu,  7 Apr 2016 17:14:21 -0400 (EDT)
Received: by mail-qk0-f174.google.com with SMTP id i4so36556302qkc.3
        for <linux-mm@kvack.org>; Thu, 07 Apr 2016 14:14:21 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z203si7363253qka.44.2016.04.07.14.14.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Apr 2016 14:14:20 -0700 (PDT)
Date: Thu, 7 Apr 2016 23:14:13 +0200
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC v1] mm: SLAB freelist randomization
Message-ID: <20160407231413.53e371ff@redhat.com>
In-Reply-To: <CAGXu5jLEENTFL_NYA5r4SqmUefkEwL68_Br6bX_RY2xNv95GVg@mail.gmail.com>
References: <1459971348-81477-1-git-send-email-thgarnie@google.com>
	<CAGXu5jLEENTFL_NYA5r4SqmUefkEwL68_Br6bX_RY2xNv95GVg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: brouer@redhat.com, Thomas Garnier <thgarnie@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Laura Abbott <labbott@fedoraproject.org>


On Wed, 6 Apr 2016 14:45:30 -0700 Kees Cook <keescook@chromium.org> wrote:

> On Wed, Apr 6, 2016 at 12:35 PM, Thomas Garnier <thgarnie@google.com> wrote:
[...]
> > re-used on slab creation for performance.  
> 
> I'd like to see some benchmark results for this so the Kconfig can
> include the performance characteristics. I recommend using hackbench
> and kernel build times with a before/after comparison.
> 

It looks like it only happens on init, right? (Thus must bench tools
might not be the right choice).

My slab tools for benchmarking the fastpath is here:
 https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/mm/slab_bulk_test01.c

And I also carry a version of Christoph's slab bench tool:
 https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/mm/slab_test.c

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

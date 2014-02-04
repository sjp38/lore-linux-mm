Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f169.google.com (mail-ob0-f169.google.com [209.85.214.169])
	by kanga.kvack.org (Postfix) with ESMTP id 1EDE06B005A
	for <linux-mm@kvack.org>; Tue,  4 Feb 2014 12:11:06 -0500 (EST)
Received: by mail-ob0-f169.google.com with SMTP id wo20so9914015obc.0
        for <linux-mm@kvack.org>; Tue, 04 Feb 2014 09:11:05 -0800 (PST)
Received: from mail-oa0-x22a.google.com (mail-oa0-x22a.google.com [2607:f8b0:4003:c02::22a])
        by mx.google.com with ESMTPS id jb8si12278638obb.1.2014.02.04.09.11.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 04 Feb 2014 09:11:05 -0800 (PST)
Received: by mail-oa0-f42.google.com with SMTP id i7so10225110oag.1
        for <linux-mm@kvack.org>; Tue, 04 Feb 2014 09:11:05 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.02.1402031308300.7898@chino.kir.corp.google.com>
References: <1391446195-9457-1-git-send-email-kosaki.motohiro@gmail.com> <alpine.DEB.2.02.1402031308300.7898@chino.kir.corp.google.com>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Tue, 4 Feb 2014 12:10:45 -0500
Message-ID: <CAHGf_=qhRvcJAP0cwDgAjuPewmUoRe+sJZCDJ_uik48RXSaOZw@mail.gmail.com>
Subject: Re: [PATCH] mm: __set_page_dirty_nobuffers uses spin_lock_irqseve
 instead of spin_lock_irq
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <jweiner@redhat.com>, stable@vger.kernel.org

> Indeed, good catch.  Do we need the same treatment for
> __set_page_dirty_buffers() that can be called by way of
> clear_page_dirty_for_io()?

Indeed. I posted a patch fixed __set_page_dirty() too. plz see

Subject: [PATCH] __set_page_dirty uses spin_lock_irqsave instead of
spin_lock_irq

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

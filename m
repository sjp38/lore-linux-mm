Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f54.google.com (mail-ee0-f54.google.com [74.125.83.54])
	by kanga.kvack.org (Postfix) with ESMTP id E628B6B0031
	for <linux-mm@kvack.org>; Tue, 18 Feb 2014 17:17:54 -0500 (EST)
Received: by mail-ee0-f54.google.com with SMTP id e53so8089217eek.27
        for <linux-mm@kvack.org>; Tue, 18 Feb 2014 14:17:54 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id x43si43038475eey.229.2014.02.18.14.17.52
        for <linux-mm@kvack.org>;
        Tue, 18 Feb 2014 14:17:53 -0800 (PST)
Message-ID: <5303DC0D.6090209@redhat.com>
Date: Tue, 18 Feb 2014 17:17:49 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] fs/proc/meminfo: meminfo_proc_show(): fix typo in comment
References: <20140218170027.00bcf592@redhat.com>
In-Reply-To: <20140218170027.00bcf592@redhat.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luiz Capitulino <lcapitulino@redhat.com>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, james.leddy@redhat.com

On 02/18/2014 05:00 PM, Luiz Capitulino wrote:
> It should read "reclaimable slab" and not "reclaimable swap".

Doh! My bad. Thanks for fixing it, Luiz!

> Signed-off-by: Luiz Capitulino <lcapitulino@redhat.com>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

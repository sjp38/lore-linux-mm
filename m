Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id B0DA96B0035
	for <linux-mm@kvack.org>; Wed,  5 Feb 2014 16:50:55 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id kl14so874613pab.15
        for <linux-mm@kvack.org>; Wed, 05 Feb 2014 13:50:55 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id sd3si30532436pbb.72.2014.02.05.13.50.54
        for <linux-mm@kvack.org>;
        Wed, 05 Feb 2014 13:50:54 -0800 (PST)
Date: Wed, 5 Feb 2014 13:50:52 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v7 1/3] mm: add kstrdup_trimnl function
Message-Id: <20140205135052.4066b67689cbf47c551d30a9@linux-foundation.org>
In-Reply-To: <1391546631-7715-2-git-send-email-sebastian.capella@linaro.org>
References: <1391546631-7715-1-git-send-email-sebastian.capella@linaro.org>
	<1391546631-7715-2-git-send-email-sebastian.capella@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Capella <sebastian.capella@linaro.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-pm@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, Michel Lespinasse <walken@google.com>, Shaohua Li <shli@kernel.org>, Jerome Marchand <jmarchan@redhat.com>, Mikulas Patocka <mpatocka@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Joe Perches <joe@perches.com>, David Rientjes <rientjes@google.com>, Alexey Dobriyan <adobriyan@gmail.com>

On Tue,  4 Feb 2014 12:43:49 -0800 Sebastian Capella <sebastian.capella@linaro.org> wrote:

> kstrdup_trimnl creates a duplicate of the passed in
> null-terminated string.  If a trailing newline is found, it
> is removed before duplicating.  This is useful for strings
> coming from sysfs that often include trailing whitespace due to
> user input.

hm, why?  I doubt if any caller of this wants to retain leading and/or
trailing spaces and/or tabs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

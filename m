Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f46.google.com (mail-oa0-f46.google.com [209.85.219.46])
	by kanga.kvack.org (Postfix) with ESMTP id 44E036B0035
	for <linux-mm@kvack.org>; Mon,  3 Feb 2014 18:08:17 -0500 (EST)
Received: by mail-oa0-f46.google.com with SMTP id n16so8855042oag.5
        for <linux-mm@kvack.org>; Mon, 03 Feb 2014 15:08:17 -0800 (PST)
Received: from mail-ob0-x22f.google.com (mail-ob0-x22f.google.com [2607:f8b0:4003:c01::22f])
        by mx.google.com with ESMTPS id kb7si10585073oeb.141.2014.02.03.15.08.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 03 Feb 2014 15:08:16 -0800 (PST)
Received: by mail-ob0-f175.google.com with SMTP id wn1so8573218obc.34
        for <linux-mm@kvack.org>; Mon, 03 Feb 2014 15:08:16 -0800 (PST)
Message-ID: <52F0215B.5040209@lwfinger.net>
Date: Mon, 03 Feb 2014 17:08:11 -0600
From: Larry Finger <Larry.Finger@lwfinger.net>
MIME-Version: 1.0
Subject: Re: Kernel WARNING splat in 3.14-rc1
References: <52EFF658.2080001@lwfinger.net> <alpine.DEB.2.02.1402031236250.7898@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1402031236250.7898@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On 02/03/2014 02:39 PM, David Rientjes wrote:
> Commit c65c1877bd68 ("slub: use lockdep_assert_held") incorrectly required
> that add_full() and remove_full() hold n->list_lock.  The lock is only
> taken when kmem_cache_debug(s), since that's the only time it actually
> does anything.
>
> Require that the lock only be taken under such a condition.
>
> Reported-by: Larry Finger <Larry.Finger@lwfinger.net>
> Signed-off-by: David Rientjes <rientjes@google.com>

You may add a "Tested-by: Larry Finger <Larry.Finger@lwfinger.net>". The patch 
cleans up the splat on my system. Thanks for the quick response.

Larry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f169.google.com (mail-lb0-f169.google.com [209.85.217.169])
	by kanga.kvack.org (Postfix) with ESMTP id 9F02B6B0260
	for <linux-mm@kvack.org>; Thu, 23 Jul 2015 03:58:13 -0400 (EDT)
Received: by lbbyj8 with SMTP id yj8so152237384lbb.0
        for <linux-mm@kvack.org>; Thu, 23 Jul 2015 00:58:12 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id bd7si3425799lab.39.2015.07.23.00.58.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Jul 2015 00:58:11 -0700 (PDT)
Date: Thu, 23 Jul 2015 10:57:46 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH -mm v9 7/8] proc: export idle flag via kpageflags
Message-ID: <20150723075746.GA19029@esperanza>
References: <cover.1437303956.git.vdavydov@parallels.com>
 <4c1eb396150ee14d7c3abf1a6f36ec8cc9dd9435.1437303956.git.vdavydov@parallels.com>
 <20150721163500.528bd39bbbc71abc3c8d429b@linux-foundation.org>
 <20150722162528.GN23374@esperanza>
 <20150722124421.3313e8f007d76b386e1d61ec@linux-foundation.org>
 <CAJu=L5-QKjd8ZjsUY8xrrtVB0k=aK5HSQAvscmqRjoJapj3_-A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <CAJu=L5-QKjd8ZjsUY8xrrtVB0k=aK5HSQAvscmqRjoJapj3_-A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andres Lagar-Cavilla <andreslc@google.com>
Cc: Minchan Kim <minchan@kernel.org>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel
 Lespinasse <walken@google.com>, David Rientjes <rientjes@google.com>, Pavel
 Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jonathan Corbet <corbet@lwn.net>, linux-api@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Jul 22, 2015 at 01:46:21PM -0700, Andres Lagar-Cavilla wrote:
> In page_referenced_one:
> 
> +       if (referenced)
> +               clear_page_idle(page);
> 

Yep, that's it. Thanks, Andres.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

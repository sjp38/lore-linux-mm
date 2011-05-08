Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 35EB56B0012
	for <linux-mm@kvack.org>; Sun,  8 May 2011 17:45:00 -0400 (EDT)
Received: by gwaa12 with SMTP id a12so2263359gwa.14
        for <linux-mm@kvack.org>; Sun, 08 May 2011 14:44:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4DC70B45.3020503@redhat.com>
References: <20110508211834.GA4410@maxin>
	<4DC70B45.3020503@redhat.com>
Date: Mon, 9 May 2011 00:44:58 +0300
Message-ID: <BANLkTi=ksGXYBYx39xxQ51VZVT6u4ANq0g@mail.gmail.com>
Subject: Re: [PATCH] mm: memory: remove unreachable code
From: Maxin John <maxin.john@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, walken@google.com, aarcange@redhat.com, hughd@google.com, linux-mm@kvack.org

Hi,

>
> Is it really impossible for vma->vm_ops->access to return a
> positive value?
>

Got it .. Thank you very much for pointing it out.

Best Regards,
Maxin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

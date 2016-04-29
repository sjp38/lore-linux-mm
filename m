Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 25E536B007E
	for <linux-mm@kvack.org>; Fri, 29 Apr 2016 17:06:30 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e190so256509680pfe.3
        for <linux-mm@kvack.org>; Fri, 29 Apr 2016 14:06:30 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id gs6si19960399pac.81.2016.04.29.14.06.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Apr 2016 14:06:29 -0700 (PDT)
Date: Fri, 29 Apr 2016 14:06:28 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: link references in the merged patch
Message-Id: <20160429140628.2f74b36a4bb123a3b81197ea@linux-foundation.org>
In-Reply-To: <20160429081601.GB21977@dhcp22.suse.cz>
References: <20160429081601.GB21977@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org

On Fri, 29 Apr 2016 10:16:02 +0200 Michal Hocko <mhocko@kernel.org> wrote:

> Hi Andrew,
> I was suggesting this during your mm workflow session at LSF/MM so this
> is just a friendly reminder. Could you add something like tip tree and
> reference the original email where the patch came from? Tip uses
> 
> Link: http://lkml.kernel.org/r/$msg_id
> 
> and this is really helpful when trying to find the discussion around the
> patch. I would even welcome to add such a link for each follow up -fix*
> patches and do
> [ $email: $(comment for the follow up chaneg)]
> Link: http://lkml.kernel.org/r/$msg_id
> 
> So it is clear what the follow up change was.
> 

Yeah, that's in my todo list (along with "do expense reports", sigh).
But who ever reads those things?

<fiddle fiddle>

OK, let's see how this goes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

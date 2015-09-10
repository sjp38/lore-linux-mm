Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 741856B0038
	for <linux-mm@kvack.org>; Thu, 10 Sep 2015 05:31:53 -0400 (EDT)
Received: by wicgb1 with SMTP id gb1so16860852wic.1
        for <linux-mm@kvack.org>; Thu, 10 Sep 2015 02:31:53 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o12si10529981wik.94.2015.09.10.02.31.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 10 Sep 2015 02:31:52 -0700 (PDT)
Subject: Re: [PATCH v2] mlock.2: mlock2.2: Add entry to for new mlock2 syscall
References: <1441030820-2960-1-git-send-email-emunson@akamai.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55F14E05.6020304@suse.cz>
Date: Thu, 10 Sep 2015 11:31:49 +0200
MIME-Version: 1.0
In-Reply-To: <1441030820-2960-1-git-send-email-emunson@akamai.com>
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@akamai.com>, mtk.manpages@gmail.com
Cc: Michal Hocko <mhocko@suse.cz>, Jonathan Corbet <corbet@lwn.net>, linux-man@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 08/31/2015 04:20 PM, Eric B Munson wrote:
> Update the mlock.2 man page with information on mlock2() and the new
> mlockall() flag MCL_ONFAULT.
> 
> Signed-off-by: Eric B Munson <emunson@akamai.com>
> Acked-by: Michal Hocko <mhocko@suse.com>

Looks like I acked v1 too late and not v2, so:

Acked-by: Vlastimil Babka <vbabka@suse.cz>

However, looks like it won't be in Linux 4.3 so that part is outdated.
Also, what about glibc wrapper for mlock2()? Does it have to come before or
after the manpage and who gets it in?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

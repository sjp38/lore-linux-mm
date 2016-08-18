Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2109A83099
	for <linux-mm@kvack.org>; Thu, 18 Aug 2016 10:41:53 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id k135so13925002lfb.2
        for <linux-mm@kvack.org>; Thu, 18 Aug 2016 07:41:53 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id o10si30322900wmo.125.2016.08.18.07.41.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Aug 2016 07:41:51 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id q128so5894939wma.1
        for <linux-mm@kvack.org>; Thu, 18 Aug 2016 07:41:51 -0700 (PDT)
Date: Thu, 18 Aug 2016 16:41:49 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] proc, smaps: reduce printing overhead
Message-ID: <20160818144149.GO30162@dhcp22.suse.cz>
References: <1471519888-13829-1-git-send-email-mhocko@kernel.org>
 <1471526765.4319.31.camel@perches.com>
 <20160818142616.GN30162@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160818142616.GN30162@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Jann Horn <jann@thejh.net>

On Thu 18-08-16 16:26:16, Michal Hocko wrote:
> b) doesn't it try to be overly clever when doing that in the caller
> doesn't cost all that much? Sure you can save few bytes in the spaces
> but then I would just argue to use \t rather than fixed string length.

ohh, I misread the code. It tries to emulate the width formater. But is
this really necessary? Do we know about any tools doing a fixed string
parsing?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

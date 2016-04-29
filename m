Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id D6EED6B0005
	for <linux-mm@kvack.org>; Fri, 29 Apr 2016 04:16:04 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id k200so92795962lfg.1
        for <linux-mm@kvack.org>; Fri, 29 Apr 2016 01:16:04 -0700 (PDT)
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com. [74.125.82.44])
        by mx.google.com with ESMTPS id c5si15955887wjm.164.2016.04.29.01.16.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Apr 2016 01:16:03 -0700 (PDT)
Received: by mail-wm0-f44.google.com with SMTP id e201so17539612wme.0
        for <linux-mm@kvack.org>; Fri, 29 Apr 2016 01:16:03 -0700 (PDT)
Date: Fri, 29 Apr 2016 10:16:02 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: link references in the merged patch
Message-ID: <20160429081601.GB21977@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org

Hi Andrew,
I was suggesting this during your mm workflow session at LSF/MM so this
is just a friendly reminder. Could you add something like tip tree and
reference the original email where the patch came from? Tip uses

Link: http://lkml.kernel.org/r/$msg_id

and this is really helpful when trying to find the discussion around the
patch. I would even welcome to add such a link for each follow up -fix*
patches and do
[ $email: $(comment for the follow up chaneg)]
Link: http://lkml.kernel.org/r/$msg_id

So it is clear what the follow up change was.

Thanks a lot!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

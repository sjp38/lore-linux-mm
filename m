Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f177.google.com (mail-qk0-f177.google.com [209.85.220.177])
	by kanga.kvack.org (Postfix) with ESMTP id 6A36D6B0255
	for <linux-mm@kvack.org>; Tue,  1 Sep 2015 08:51:54 -0400 (EDT)
Received: by qkcj187 with SMTP id j187so36950953qkc.2
        for <linux-mm@kvack.org>; Tue, 01 Sep 2015 05:51:54 -0700 (PDT)
Received: from mail.mgebm.net (rumi.csail.mit.edu. [128.30.29.5])
        by mx.google.com with ESMTPS id e72si11009134qhc.90.2015.09.01.05.51.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Sep 2015 05:51:53 -0700 (PDT)
In-Reply-To: <20150828141829.GD5301@dhcp22.suse.cz>
References: <1440613465-30393-1-git-send-email-emunson@akamai.com> <1440613465-30393-4-git-send-email-emunson@akamai.com> <20150828141829.GD5301@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain;
 charset=UTF-8
Subject: Re: [PATCH v8 3/6] mm: Introduce VM_LOCKONFAULT
From: Eric B Munson <emunson@mgebm.net>
Date: Tue, 01 Sep 2015 08:51:35 -0400
Message-ID: <450C6E20-C941-4BE2-853B-0203C6BE38F6@mgebm.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Eric B Munson <emunson@akamai.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Jonathan Corbet <corbet@lwn.net>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org



On August 28, 2015 10:18:30 AM EDT, Michal Hocko <mhocko@kernel.org> wrote:

>
>Why do we need to export this? Neither of the consumers care and should
>care. VM_LOCKONFAULT should never be set without VM_LOCKED which is the
>only thing that we should care about.

I am out of the office and I don't know if I will be back in time to respin this series without this hunk.  Andrew, can you remove the export of VM_LOCKONFAULT to the rmap code?

Thank,
Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

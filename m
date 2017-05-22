Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id B0848831F4
	for <linux-mm@kvack.org>; Mon, 22 May 2017 09:41:18 -0400 (EDT)
Received: by mail-ua0-f197.google.com with SMTP id k4so33649037uaa.0
        for <linux-mm@kvack.org>; Mon, 22 May 2017 06:41:18 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id o132si6110044vke.89.2017.05.22.06.41.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 May 2017 06:41:17 -0700 (PDT)
Subject: Re: [v4 1/1] mm: Adaptive hash table scaling
References: <1495300013-653283-1-git-send-email-pasha.tatashin@oracle.com>
 <1495300013-653283-2-git-send-email-pasha.tatashin@oracle.com>
 <20170522092910.GD8509@dhcp22.suse.cz>
 <f6585e67-1640-daa3-370c-f37562cb5245@oracle.com>
 <20170522133834.GL8509@dhcp22.suse.cz>
From: Pasha Tatashin <pasha.tatashin@oracle.com>
Message-ID: <6e81aa26-e43e-6264-e2f9-547531b809f5@oracle.com>
Date: Mon, 22 May 2017 09:41:08 -0400
MIME-Version: 1.0
In-Reply-To: <20170522133834.GL8509@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Ellerman <mpe@ellerman.id.au>

> 
> This is just too ugly to live, really. If we do not need adaptive
> scaling then just make it #if __BITS_PER_LONG around the code. I would
> be fine with this. A big fat warning explaining why this is 64b only
> would be appropriate.
> 

OK, let me prettify it somehow, and I will send a new patch out.

Pasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

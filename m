Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id B75CA6B0033
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 10:51:51 -0500 (EST)
Received: by mail-vk0-f69.google.com with SMTP id o130so16481527vka.18
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 07:51:51 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id v63si2006319vkg.45.2017.11.27.07.51.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Nov 2017 07:51:50 -0800 (PST)
Subject: Re: [RFC PATCH 0/2] mm: introduce MAP_FIXED_SAFE
References: <20171116101900.13621-1-mhocko@kernel.org>
 <20171116121438.6vegs4wiahod3byl@dhcp22.suse.cz>
 <20171124085405.dwln5k3dk7fdio7e@dhcp22.suse.cz>
From: Khalid Aziz <khalid.aziz@oracle.com>
Message-ID: <4f5eb24c-5af2-eebf-d54f-875f4b259793@oracle.com>
Date: Mon, 27 Nov 2017 08:51:10 -0700
MIME-Version: 1.0
In-Reply-To: <20171124085405.dwln5k3dk7fdio7e@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, linux-api@vger.kernel.org
Cc: Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org, Abdul Haleem <abdhalee@linux.vnet.ibm.com>, Joel Stanley <joel@jms.id.au>, Kees Cook <keescook@chromium.org>

On 11/24/2017 01:54 AM, Michal Hocko wrote:
> Are there any more concerns? So far the biggest one was the name. The
> other which suggests a flag as a modifier has been sorted out hopefully.
> Is there anymore more before we can consider this for merging? Well
> except for man page update which I will prepare of course. Can we target
> this to 4.16?

I do not have concerns with this approach. I prefer a new flag as 
opposed to a modifier and the name is ok by me.

Reviewed-by: Khalid Aziz <khalid.aziz@oracle.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

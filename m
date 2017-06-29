Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id C25AE6B0292
	for <linux-mm@kvack.org>; Thu, 29 Jun 2017 08:11:56 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id b184so1797866wme.14
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 05:11:56 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 101si4073279wrc.396.2017.06.29.05.11.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 29 Jun 2017 05:11:55 -0700 (PDT)
Date: Thu, 29 Jun 2017 14:11:54 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm: Drop useless local parameters of
 __register_one_node()
Message-ID: <20170629121154.GA5039@dhcp22.suse.cz>
References: <1498013846-20149-1-git-send-email-douly.fnst@cn.fujitsu.com>
 <20170629111217.GA5032@dhcp22.suse.cz>
 <c831fee0-4226-f519-6ba6-092f84928af3@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c831fee0-4226-f519-6ba6-092f84928af3@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dou Liyang <douly.fnst@cn.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, David Rientjes <rientjes@google.com>, isimatu.yasuaki@jp.fujitsu.com

On Thu 29-06-17 19:58:52, Dou Liyang wrote:
> Hi Michal,
> 
> At 06/29/2017 07:12 PM, Michal Hocko wrote:
> >On Wed 21-06-17 10:57:26, Dou Liyang wrote:
> >>... initializes local parameters "p_node" & "parent" for
> >>register_node().
> >>
> >>But, register_node() does not use them.
> >>
> >>Remove the related code of "parent" node, cleanup __register_one_node()
> >>and register_node().
> >>
> >>Cc: Andrew Morton <akpm@linux-foundation.org>
> >>Cc: David Rientjes <rientjes@google.com>
> >>Cc: Michal Hocko <mhocko@kernel.org>
> >>Cc: isimatu.yasuaki@jp.fujitsu.com
> >>Signed-off-by: Dou Liyang <douly.fnst@cn.fujitsu.com>
> >>Acked-by: David Rientjes <rientjes@google.com>
> >
> >I am sorry, this slipped through cracks.
> >Acked-by: Michal Hocko <mhocko@suse.com>
> 
> Thanks for your Acked-by, but this patch has been added to the -mm tree.
> Its filename is
>    mm-drop-useless-local-parameters-of-__register_one_node.patch

Yeah, don't worry. Andrew will add the acked-by in his tree.

> This patch should soon appear at
> 
> http://ozlabs.org/~akpm/mmots/broken-out/mm-drop-useless-local-parameters-of-__register_one_node.patch
> and later at
> 
> http://ozlabs.org/~akpm/mmotm/broken-out/mm-drop-useless-local-parameters-of-__register_one_node.patch
> 
> I don't know what should I do next ? :)

Wait for Andrew to send this to Linus during the next merge window.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

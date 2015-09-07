Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 9AF016B0038
	for <linux-mm@kvack.org>; Mon,  7 Sep 2015 03:24:21 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so73359958wic.0
        for <linux-mm@kvack.org>; Mon, 07 Sep 2015 00:24:21 -0700 (PDT)
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com. [209.85.212.169])
        by mx.google.com with ESMTPS id o7si13674951wjq.49.2015.09.07.00.24.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Sep 2015 00:24:20 -0700 (PDT)
Received: by wiclk2 with SMTP id lk2so73526067wic.1
        for <linux-mm@kvack.org>; Mon, 07 Sep 2015 00:24:19 -0700 (PDT)
Date: Mon, 7 Sep 2015 09:24:18 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/mmap.c: Only call vma_unlock_anon_vm() when failure
 occurs in expand_upwards() and expand_downwards()
Message-ID: <20150907072418.GA6022@dhcp22.suse.cz>
References: <COL130-W9593F65D7C12B5353FE079B96B0@phx.gbl>
 <55E5AD17.6060901@hotmail.com>
 <COL130-W4895D78CDAEA273AB88C53B96A0@phx.gbl>
 <55E96E01.5010605@hotmail.com>
 <COL130-W49B21394779B6662272AD0B9570@phx.gbl>
 <55EAC021.3080205@hotmail.com>
 <COL130-W64DF8D947992A52E4CBE40B9560@phx.gbl>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <COL130-W64DF8D947992A52E4CBE40B9560@phx.gbl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gang <xili_gchen_5257@hotmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory <linux-mm@kvack.org>, kernel mailing list <linux-kernel@vger.kernel.org>, Chen Gang <gchen_5i5j@21cn.com>

On Sat 05-09-15 18:11:40, Chen Gang wrote:
> Hello All:
> 
> I have send 2 new patches about mm, and 1 patch for arch metag via my
> 21cn mail. Could any members help to tell me, whether he/she have
> received the patches or not?

Yes they seem to be in the archive.
http://lkml.kernel.org/r/COL130-W64A6555222F8CEDA513171B9560%40phx.gbl
http://lkml.kernel.org/r/COL130-W16C972B0457D5C7C9CB06B9560%40phx.gbl

You can check that easily by http://lkml.kernel.org/r/$MESSAGE_ID
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

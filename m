Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id A0C0D6B03DF
	for <linux-mm@kvack.org>; Mon,  8 May 2017 21:41:55 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id t12so27133183pgo.7
        for <linux-mm@kvack.org>; Mon, 08 May 2017 18:41:55 -0700 (PDT)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id y70si4100020pfj.169.2017.05.08.18.41.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 May 2017 18:41:54 -0700 (PDT)
Received: by mail-pg0-x244.google.com with SMTP id u187so12895733pgb.1
        for <linux-mm@kvack.org>; Mon, 08 May 2017 18:41:54 -0700 (PDT)
Message-ID: <1494294107.15016.3.camel@gmail.com>
Subject: Re: [PATCH v2 1/2] mm: Uncharge poisoned pages
From: Balbir Singh <bsingharora@gmail.com>
Date: Tue, 09 May 2017 11:41:47 +1000
In-Reply-To: <03a7ec34-106e-3eb6-0b05-f77a40a2d6b9@linux.vnet.ibm.com>
References: <1493130472-22843-1-git-send-email-ldufour@linux.vnet.ibm.com>
	 <1493130472-22843-2-git-send-email-ldufour@linux.vnet.ibm.com>
	 <20170427143721.GK4706@dhcp22.suse.cz> <87pofxk20k.fsf@firstfloor.org>
	 <20170428060755.GA8143@dhcp22.suse.cz>
	 <20170428073136.GE8143@dhcp22.suse.cz>
	 <3eb86373-dafc-6db9-82cd-84eb9e8b0d37@linux.vnet.ibm.com>
	 <20170428134831.GB26705@dhcp22.suse.cz>
	 <c8ce6056-e89b-7470-c37a-85ab5bc7a5b2@linux.vnet.ibm.com>
	 <20170502185507.GB19165@dhcp22.suse.cz> <1493860869.8082.1.camel@gmail.com>
	 <03a7ec34-106e-3eb6-0b05-f77a40a2d6b9@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>, Michal Hocko <mhocko@kernel.org>, Andi Kleen <andi@firstfloor.org>, Johannes Weiner <hannes@cmpxchg.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, Vladimir Davydov <vdavydov.dev@gmail.com>

On Mon, 2017-05-08 at 12:42 +0200, Laurent Dufour wrote:
> Sorry Balbir,
> 
> You pointed this out since the beginning but I missed your comment.
> My mistake.
>

No worries, as long as the right thing gets in

Balbir Singh 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id C6B576B0253
	for <linux-mm@kvack.org>; Wed, 26 Aug 2015 18:02:51 -0400 (EDT)
Received: by pacti10 with SMTP id ti10so1081085pac.0
        for <linux-mm@kvack.org>; Wed, 26 Aug 2015 15:02:51 -0700 (PDT)
Received: from mail-pa0-x236.google.com (mail-pa0-x236.google.com. [2607:f8b0:400e:c03::236])
        by mx.google.com with ESMTPS id xr6si98709pab.78.2015.08.26.15.02.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Aug 2015 15:02:51 -0700 (PDT)
Received: by pacti10 with SMTP id ti10so1080713pac.0
        for <linux-mm@kvack.org>; Wed, 26 Aug 2015 15:02:50 -0700 (PDT)
Date: Wed, 26 Aug 2015 15:02:49 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v5 2/2] mm: hugetlb: proc: add HugetlbPages field to
 /proc/PID/status
In-Reply-To: <20150826063813.GA25196@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1508261451540.19139@chino.kir.corp.google.com>
References: <20150812000336.GB32192@hori1.linux.bs1.fc.nec.co.jp> <1440059182-19798-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1440059182-19798-3-git-send-email-n-horiguchi@ah.jp.nec.com> <20150820110004.GB4632@dhcp22.suse.cz> <20150820233450.GB10807@hori1.linux.bs1.fc.nec.co.jp>
 <20150821065321.GD23723@dhcp22.suse.cz> <20150821163033.GA4600@Sligo.logfs.org> <20150824085127.GB17078@dhcp22.suse.cz> <alpine.DEB.2.10.1508251620570.10653@chino.kir.corp.google.com> <20150826063813.GA25196@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="397176738-746873092-1440626014=:19139"
Content-ID: <alpine.DEB.2.10.1508261453360.19139@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: =?UTF-8?Q?J=C3=B6rn_Engel?= <joern@purestorage.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--397176738-746873092-1440626014=:19139
Content-Type: TEXT/PLAIN; CHARSET=UTF-8
Content-Transfer-Encoding: 8BIT
Content-ID: <alpine.DEB.2.10.1508261453361.19139@chino.kir.corp.google.com>

On Wed, 26 Aug 2015, Michal Hocko wrote:

> I thought the purpose was to give the amount of hugetlb based
> resident memory.

Persistent hugetlb memory is always resident, the goal is to show what is 
currently mapped.

> At least this is what JA?rn was asking for AFAIU.
> /proc/<pid>/status should be as lightweight as possible. The current
> implementation is quite heavy as already pointed out. So I am really
> curious whether this is _really_ needed. I haven't heard about a real
> usecase except for top displaying HRss which doesn't need the break
> down values. You have brought that up already
> http://marc.info/?l=linux-mm&m=143941143109335&w=2 and nobody actually
> asked for it. "I do not mind having it" is not an argument for inclusion
> especially when the implementation is more costly and touches hot paths.
> 

It iterates over HUGE_MAX_HSTATE and reads atomic usage counters twice.  
On x86, HUGE_MAX_HSTATE == 2.  I don't consider that to be expensive.

If you are concerned about the memory allocation of struct hugetlb_usage, 
it could easily be embedded directly in struct mm_struct.
--397176738-746873092-1440626014=:19139--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

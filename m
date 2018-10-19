Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 40CAA6B0269
	for <linux-mm@kvack.org>; Fri, 19 Oct 2018 04:28:04 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id e5-v6so20093418eda.4
        for <linux-mm@kvack.org>; Fri, 19 Oct 2018 01:28:04 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r28-v6sor16742073eda.26.2018.10.19.01.28.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 19 Oct 2018 01:28:03 -0700 (PDT)
Date: Fri, 19 Oct 2018 08:28:01 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] mm/sparse: remove a check that compare if unsigned
 variable is negative
Message-ID: <20181019082801.kbnqxx5ozghy3p3b@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <1539447319-5383-1-git-send-email-penghao122@sina.com.cn>
 <CAGM2reYqEpY9KbMDU6uSaCuzsyN6qcXit930vbWk54PLhvZxZg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGM2reYqEpY9KbMDU6uSaCuzsyN6qcXit930vbWk54PLhvZxZg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@gmail.com>
Cc: penghao122@sina.com.cn, Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, pasha.tatashin@oracle.com, osalvador@suse.de, LKML <linux-kernel@vger.kernel.org>, peng.hao2@zte.com.cn

On Sat, Oct 13, 2018 at 01:04:45PM -0400, Pavel Tatashin wrote:
>This is incorrect: next_present_section_nr() returns "int" and -1 no
>next section, this change would lead to infinite loop.

Yes, the -1 is a very special value.

-- 
Wei Yang
Help you, Help me

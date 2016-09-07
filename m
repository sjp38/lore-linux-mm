Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id D86556B0038
	for <linux-mm@kvack.org>; Tue,  6 Sep 2016 23:08:21 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id m139so3476688wma.0
        for <linux-mm@kvack.org>; Tue, 06 Sep 2016 20:08:21 -0700 (PDT)
Received: from mail-wm0-x231.google.com (mail-wm0-x231.google.com. [2a00:1450:400c:c09::231])
        by mx.google.com with ESMTPS id vm5si33970742wjc.40.2016.09.06.20.08.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Sep 2016 20:08:20 -0700 (PDT)
Received: by mail-wm0-x231.google.com with SMTP id w12so7445351wmf.0
        for <linux-mm@kvack.org>; Tue, 06 Sep 2016 20:08:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <57CF28C5.3090006@intel.com>
References: <1473140072-24137-2-git-send-email-khandual@linux.vnet.ibm.com>
 <1473150666-3875-1-git-send-email-khandual@linux.vnet.ibm.com> <57CF28C5.3090006@intel.com>
From: Kees Cook <keescook@chromium.org>
Date: Tue, 6 Sep 2016 20:08:18 -0700
Message-ID: <CAGXu5jK_sKa2dcVrwhXdp=ZA=ACEY6vmd-LDoy8KmMtCn_aDzw@mail.gmail.com>
Subject: Re: [PATCH V3] mm: Add sysfs interface to dump each node's zonelist information
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Tue, Sep 6, 2016 at 1:36 PM, Dave Hansen <dave.hansen@intel.com> wrote:
> On 09/06/2016 01:31 AM, Anshuman Khandual wrote:
>> [NODE (0)]
>>         ZONELIST_FALLBACK
>>         (0) (node 0) (zone DMA c00000000140c000)
>>         (1) (node 1) (zone DMA c000000100000000)
>>         (2) (node 2) (zone DMA c000000200000000)
>>         (3) (node 3) (zone DMA c000000300000000)
>>         ZONELIST_NOFALLBACK
>>         (0) (node 0) (zone DMA c00000000140c000)
>
> Don't we have some prohibition on dumping out kernel addresses like this
> so that attackers can't trivially defeat kernel layout randomization?

Anything printing memory addresses should be using %pK (not %lx as done here).

-Kees

-- 
Kees Cook
Nexus Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

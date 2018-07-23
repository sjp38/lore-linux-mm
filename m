Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 999076B000A
	for <linux-mm@kvack.org>; Mon, 23 Jul 2018 16:31:11 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id d10-v6so1130313pll.22
        for <linux-mm@kvack.org>; Mon, 23 Jul 2018 13:31:11 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 17-v6sor2398633pgp.145.2018.07.23.13.31.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 23 Jul 2018 13:31:10 -0700 (PDT)
Date: Mon, 23 Jul 2018 13:31:08 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: thp: remove use_zero_page sysfs knob
In-Reply-To: <3118b646-681e-a2aa-dc7b-71d4821fa50f@linux.alibaba.com>
Message-ID: <alpine.DEB.2.21.1807231329080.105582@chino.kir.corp.google.com>
References: <1532110430-115278-1-git-send-email-yang.shi@linux.alibaba.com> <20180720210626.5bnyddmn4avp2l3x@kshutemo-mobl1> <3118b646-681e-a2aa-dc7b-71d4821fa50f@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, hughd@google.com, aaron.lu@intel.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 20 Jul 2018, Yang Shi wrote:

> I agree to keep it for a while to let that security bug cool down, however, if
> there is no user anymore, it sounds pointless to still keep a dead knob.
> 

It's not a dead knob.  We use it, and for reasons other than 
CVE-2017-1000405.  To mitigate the cost of constantly compacting memory to 
allocate it after it has been freed due to memry pressure, we can either 
continue to disable it, allow it to be persistently available, or use a 
new value for use_zero_page to specify it should be persistently 
available.

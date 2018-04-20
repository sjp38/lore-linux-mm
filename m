Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1814A6B0003
	for <linux-mm@kvack.org>; Fri, 20 Apr 2018 15:45:01 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id k3so5126385pff.23
        for <linux-mm@kvack.org>; Fri, 20 Apr 2018 12:45:01 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id g3si5437455pgr.635.2018.04.20.12.44.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Apr 2018 12:44:59 -0700 (PDT)
Subject: Re: [PATCH 2/2] x86, pti: fix boot warning from Global-bit setting
References: <20180417211302.421F6442@viggo.jf.intel.com>
 <20180417211304.7B3F1FDB@viggo.jf.intel.com>
 <alpine.DEB.2.21.1804201215170.1683@nanos.tec.linutronix.de>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <df7f4b2c-9048-19f5-4817-45d29eec022c@linux.intel.com>
Date: Fri, 20 Apr 2018 12:44:47 -0700
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.21.1804201215170.1683@nanos.tec.linutronix.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, mceier@gmail.com, aaro.koskinen@nokia.com, aarcange@redhat.com, luto@kernel.org, arjan@linux.intel.com, bp@alien8.de, dan.j.williams@intel.com, dwmw2@infradead.org, gregkh@linuxfoundation.org, hughd@google.com, jpoimboe@redhat.com, jgross@suse.com, keescook@google.com, torvalds@linux-foundation.org, namit@vmware.com, peterz@infradead.org

On 04/20/2018 03:16 AM, Thomas Gleixner wrote:
>> pageattr.c is not friendly when it encounters empty (zero) PTEs.  The
>> kernel linear map is exempt from these checks, but kernel text is not.
>> This patch adds the code to also exempt kernel text from these checks.
> Bah. Changelogs should tell the WHY and not the WHAT
> 
>> The proximate cause of these warnings was most likely an __init area
>> that spanned a 2MB page boundary that resulted in a "zero" PMD.
> This doesn't make any sense at all. 

I've rewritten these changelogs and added some more fixes for this set.
I'll be sending it shortly.

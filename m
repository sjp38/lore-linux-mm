Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 0CCD46B0005
	for <linux-mm@kvack.org>; Mon, 15 Feb 2016 11:29:46 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id yy13so87937476pab.3
        for <linux-mm@kvack.org>; Mon, 15 Feb 2016 08:29:46 -0800 (PST)
Received: from blackbird.sr71.net (www.sr71.net. [198.145.64.142])
        by mx.google.com with ESMTP id a10si44233664pat.183.2016.02.15.08.29.43
        for <linux-mm@kvack.org>;
        Mon, 15 Feb 2016 08:29:43 -0800 (PST)
Subject: Re: [PATCH 01/33] mm: introduce get_user_pages_remote()
References: <20160212210152.9CAD15B0@viggo.jf.intel.com>
 <20160212210154.3F0E51EA@viggo.jf.intel.com>
 <1455516578.16012.27.camel@gmail.com>
From: Dave Hansen <dave@sr71.net>
Message-ID: <56C1FCF5.804@sr71.net>
Date: Mon, 15 Feb 2016 08:29:41 -0800
MIME-Version: 1.0
In-Reply-To: <1455516578.16012.27.camel@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, torvalds@linux-foundation.org, dave.hansen@linux.intel.com, srikar@linux.vnet.ibm.com, vbabka@suse.cz, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, aarcange@redhat.com, n-horiguchi@ah.jp.nec.com, jack@suse.cz

On 02/14/2016 10:09 PM, Balbir Singh wrote:
>> > For protection keys, we need to understand whether protections
>> > should be enforced in software or not.  In general, we enforce
>> > protections when working on our own task, but not when on others.
>> > We call these "current" and "remote" operations.
>> > 
>> > This patch introduces a new get_user_pages() variant:
>> > 
>> >         get_user_pages_remote()
>> > 
>> > Which is a replacement for when get_user_pages() is called on
>> > non-current tsk/mm.
>> > 
> In summary then get_user_pages_remote() do not enforce protections?

Yes, exactly.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

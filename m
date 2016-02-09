Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 682F1828F4
	for <linux-mm@kvack.org>; Tue,  9 Feb 2016 08:07:00 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id p63so157284705wmp.1
        for <linux-mm@kvack.org>; Tue, 09 Feb 2016 05:07:00 -0800 (PST)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id q4si48889304wjx.148.2016.02.09.05.06.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Feb 2016 05:06:59 -0800 (PST)
Received: by mail-wm0-x241.google.com with SMTP id 128so3309235wmz.3
        for <linux-mm@kvack.org>; Tue, 09 Feb 2016 05:06:58 -0800 (PST)
Date: Tue, 9 Feb 2016 14:06:55 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 01/31] mm, gup: introduce concept of "foreign"
 get_user_pages()
Message-ID: <20160209130655.GA20998@gmail.com>
References: <20160129181642.98E7D468@viggo.jf.intel.com>
 <20160129181644.74134A5D@viggo.jf.intel.com>
 <20160209124649.GA20153@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160209124649.GA20153@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, torvalds@linux-foundation.org, dave.hansen@linux.intel.com, srikar@linux.vnet.ibm.com, vbabka@suse.cz, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, aarcange@redhat.com, n-horiguchi@ah.jp.nec.com, jack@suse.cz


* Ingo Molnar <mingo@kernel.org> wrote:

> Also, please split this into three patches:
> 
>  - one patch adds the _foreign() GUP variant and applies it to code that uses it
>    on remote tasks.

This reminds me: please also rename the new API to get_user_pages_remote(), as 
remote/local is the phrase we typically use in MM code.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id D1FA76B0009
	for <linux-mm@kvack.org>; Thu, 21 Jan 2016 19:28:43 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id cy9so31532772pac.0
        for <linux-mm@kvack.org>; Thu, 21 Jan 2016 16:28:43 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id c20si5342148pfj.65.2016.01.21.16.28.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Jan 2016 16:28:43 -0800 (PST)
Date: Thu, 21 Jan 2016 16:28:41 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/8] Support multi-order entries in the radix tree
Message-Id: <20160121162841.9116af529b6ce0ce6b00aefc@linux-foundation.org>
In-Reply-To: <1453213533-6040-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1453213533-6040-1-git-send-email-matthew.r.wilcox@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Shuah Khan <shuahkh@osg.samsung.com>

On Tue, 19 Jan 2016 09:25:25 -0500 Matthew Wilcox <matthew.r.wilcox@intel.com> wrote:

> Before diving into the important modifications, I add Andrew Morton's
> radix tree test harness to the tree in patches 1 & 2.  It was absolutely
> invaluable in catching some of my bugs.

(cc Shuah for tools/testing/selftests)

Cool, thanks for doing that.  I think a lot of this came from Nick Piggin
a long time ago, but I was bad about attributing it.

I wonder how good the coverage is - I don't think it's been seriously
updated since 2010 and presumably it isn't hitting on later-added
features.  Doesn't matter - someone will add things later if needed. 
And when I bug them to update the test harness ;) 

I don't think it will link on my system - I have no liburcu by default.
I wonder if this will break lots of people's "make kselftest".

I'll get all this into -next tomorrow.  Hopefully Ross will have time
to go through it sometime (non-urgently - it's 4.6 stuff).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

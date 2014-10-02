Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f52.google.com (mail-oi0-f52.google.com [209.85.218.52])
	by kanga.kvack.org (Postfix) with ESMTP id 574256B0038
	for <linux-mm@kvack.org>; Thu,  2 Oct 2014 13:03:36 -0400 (EDT)
Received: by mail-oi0-f52.google.com with SMTP id a3so2161086oib.25
        for <linux-mm@kvack.org>; Thu, 02 Oct 2014 10:03:36 -0700 (PDT)
Received: from resqmta-po-12v.sys.comcast.net (resqmta-po-12v.sys.comcast.net. [2001:558:fe16:19:96:114:154:171])
        by mx.google.com with ESMTPS id u7si8399072oek.37.2014.10.02.10.03.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 02 Oct 2014 10:03:33 -0700 (PDT)
Date: Thu, 2 Oct 2014 12:03:30 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/3] mm: generalize VM_BUG_ON() macros
In-Reply-To: <20141001130523.d7cf46e735089d681194e8e6@linux-foundation.org>
Message-ID: <alpine.DEB.2.11.1410021202370.4190@gentwo.org>
References: <1412163121-4295-1-git-send-email-kirill.shutemov@linux.intel.com> <20141001130523.d7cf46e735089d681194e8e6@linux-foundation.org>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Sasha Levin <sasha.levin@oracle.com>, Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 1 Oct 2014, Andrew Morton wrote:

> I can't say I'm a fan of this.  We don't do this sort of thing anywhere
> else in the kernel and passing different types to the same thing in
> different places is unusual and exceptional.  We gain very little from
> this so why bother?

I feel the same. This smells awfully like C++ overloading of functions
etc which I think often confuses the heck out of people.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

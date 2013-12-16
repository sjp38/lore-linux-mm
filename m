Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f53.google.com (mail-qa0-f53.google.com [209.85.216.53])
	by kanga.kvack.org (Postfix) with ESMTP id 5D88D6B0035
	for <linux-mm@kvack.org>; Mon, 16 Dec 2013 11:53:01 -0500 (EST)
Received: by mail-qa0-f53.google.com with SMTP id j5so1707245qaq.12
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 08:53:01 -0800 (PST)
Received: from b232-35.smtp-out.amazonses.com (b232-35.smtp-out.amazonses.com. [199.127.232.35])
        by mx.google.com with ESMTP id k9si9765033qat.17.2013.12.16.08.52.57
        for <linux-mm@kvack.org>;
        Mon, 16 Dec 2013 08:53:00 -0800 (PST)
Date: Mon, 16 Dec 2013 16:52:57 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC][PATCH 1/7] mm: print more details for bad_page()
In-Reply-To: <20131213235904.D69C09F7@viggo.jf.intel.com>
Message-ID: <00000142fc5326bf-37eaf439-1c10-448f-9cd3-8137290680ca-000000@email.amazonses.com>
References: <20131213235903.8236C539@viggo.jf.intel.com> <20131213235904.D69C09F7@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pravin B Shelar <pshelar@nicira.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andi Kleen <ak@linux.intel.com>

On Fri, 13 Dec 2013, Dave Hansen wrote:

> This way, the messages will show specifically why the page was
> bad, *specifically* which flags it is complaining about, if it
> was a page flag combination which was the problem.

Yes this would have been helpful in the past for me.

Reviewed-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

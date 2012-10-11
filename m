Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id F1E3A6B002B
	for <linux-mm@kvack.org>; Thu, 11 Oct 2012 18:26:04 -0400 (EDT)
Received: by mail-we0-f169.google.com with SMTP id u3so1553118wey.14
        for <linux-mm@kvack.org>; Thu, 11 Oct 2012 15:26:03 -0700 (PDT)
Message-ID: <50774779.8000005@suse.cz>
Date: Fri, 12 Oct 2012 00:26:01 +0200
From: Jiri Slaby <jslaby@suse.cz>
MIME-Version: 1.0
Subject: Re: kswapd0: wxcessive CPU usage
References: <507688CC.9000104@suse.cz> <20121011151413.3ab58542.akpm@linux-foundation.org>
In-Reply-To: <20121011151413.3ab58542.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiri Slaby <jirislaby@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On 10/12/2012 12:14 AM, Andrew Morton wrote:
> Could you please do a sysrq-T a few times while it's spinning, to
> confirm that this trace is consistently the culprit?

For me yes, shrink_slab is in the most of the traces.

-- 
js
suse labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

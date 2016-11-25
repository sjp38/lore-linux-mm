Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id E83956B0261
	for <linux-mm@kvack.org>; Fri, 25 Nov 2016 10:02:41 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id bk3so10585876wjc.4
        for <linux-mm@kvack.org>; Fri, 25 Nov 2016 07:02:41 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l66si14204926wma.114.2016.11.25.07.02.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 25 Nov 2016 07:02:40 -0800 (PST)
Subject: Re: The scan_unevictable_pages sysctl/node-interface has been
 disabled for lack of a legitimate use case!
References: <A3F4FE4A-B6E3-4B04-83B3-E328808B7951@fb.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <c82c3221-f121-9691-fdf3-1f44e502d6a6@suse.cz>
Date: Fri, 25 Nov 2016 16:02:39 +0100
MIME-Version: 1.0
In-Reply-To: <A3F4FE4A-B6E3-4B04-83B3-E328808B7951@fb.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ramesh Shihora <rameshshihora@fb.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 10/28/2016 05:58 PM, Ramesh Shihora wrote:
> Seeing on one of our server:
>
>
>
> sysctl: The scan_unevictable_pages sysctl/node-interface has been
> disabled for lack of a legitimate use case.  If you have one, please
> send an email to linux-mm@kvack.org <mailto:linux-mm@kvack.org>.

Note that "If you have one" refers to "a legitimate use case". But looks 
like you're not the first one to be confused by thinking it refers just 
to seeing the log line?

>
> Thanks,
>
> Ramesh
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

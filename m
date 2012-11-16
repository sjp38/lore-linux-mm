Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 97F266B002B
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 02:45:27 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id d41so1746803eek.14
        for <linux-mm@kvack.org>; Thu, 15 Nov 2012 23:45:26 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <50A5DFA4.2030700@gmail.com>
References: <5094E4A3.8020409@gmail.com>
	<50A5DFA4.2030700@gmail.com>
Date: Fri, 16 Nov 2012 08:45:25 +0100
Message-ID: <CANGUGtAF0CRzYOkjqCXvxukw99Y9G02Ht=DZ8viRHqThGHLSSQ@mail.gmail.com>
Subject: Re: [PATCH 20/21] mm: drop vmtruncate
From: Marco Stornelli <marco.stornelli@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jaegeuk Hanse <jaegeuk.hanse@gmail.com>
Cc: Linux FS Devel <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

2012/11/16 Jaegeuk Hanse <jaegeuk.hanse@gmail.com>:
> On 11/03/2012 05:32 PM, Marco Stornelli wrote:
>>
>> Removed vmtruncate
>
>
> Hi Marco,
>
> Could you explain me why vmtruncate need remove? What's the problem and how
> to substitute it?
>
> Regards,
> Jaegeuk
>

vmtruncate is a deprecated function so it'd be better to remove it.
The truncate sequence is changed for several reasons. The
documentation is clear: "This function is deprecated and
truncate_setsize or truncate_pagecache should be used instead,
together with filesystem specific block truncation." In addition, we
can remove the truncate callback from the inode struct saving 4/8
bytes.

Marco

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

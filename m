Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f182.google.com (mail-ve0-f182.google.com [209.85.128.182])
	by kanga.kvack.org (Postfix) with ESMTP id 3D39B6B0039
	for <linux-mm@kvack.org>; Sat, 15 Mar 2014 12:22:12 -0400 (EDT)
Received: by mail-ve0-f182.google.com with SMTP id jw12so4096429veb.13
        for <linux-mm@kvack.org>; Sat, 15 Mar 2014 09:22:11 -0700 (PDT)
Received: from cdptpa-omtalb.mail.rr.com (cdptpa-omtalb.mail.rr.com. [75.180.132.120])
        by mx.google.com with ESMTP id yv18si3375440vcb.14.2014.03.15.09.22.11
        for <linux-mm@kvack.org>;
        Sat, 15 Mar 2014 09:22:11 -0700 (PDT)
Message-ID: <53247E31.7060002@ubuntu.com>
Date: Sat, 15 Mar 2014 12:22:09 -0400
From: Phillip Susi <psusi@ubuntu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] readahead.2: don't claim the call blocks until all data
 has been read
References: <1394812471-9693-1-git-send-email-psusi@ubuntu.com> <532417CA.1040300@gmail.com>
In-Reply-To: <532417CA.1040300@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Cc: linux-man@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org, Corrado Zoccolo <czoccolo@gmail.com>, "Gregory P. Smith" <gps@google.com>, Zhu Yanhai <zhu.yanhai@gmail.com>

On 03/15/2014 05:05 AM, Michael Kerrisk (man-pages) wrote:
> I've tweaked your text a bit to make some details clearer (I hope):
>
>         readahead()  initiates  readahead  on a file so that subsequent
>         reads from that file will, be satisfied from the cache, and not
>         block  on  disk I/O (assuming the readahead was initiated early
>         enough and that other activity on the system  did  not  in  the
>         meantime flush pages from the cache).

Slight grammatical error there: there's an extra comma in "file will, be".


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

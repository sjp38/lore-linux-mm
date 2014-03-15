Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 710F86B003C
	for <linux-mm@kvack.org>; Sat, 15 Mar 2014 12:25:57 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id fb1so3976537pad.1
        for <linux-mm@kvack.org>; Sat, 15 Mar 2014 09:25:57 -0700 (PDT)
Received: from mail-pd0-x236.google.com (mail-pd0-x236.google.com [2607:f8b0:400e:c02::236])
        by mx.google.com with ESMTPS id tk9si6304433pac.88.2014.03.15.09.25.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 15 Mar 2014 09:25:56 -0700 (PDT)
Received: by mail-pd0-f182.google.com with SMTP id y10so3851619pdj.27
        for <linux-mm@kvack.org>; Sat, 15 Mar 2014 09:25:56 -0700 (PDT)
MIME-Version: 1.0
Reply-To: mtk.manpages@gmail.com
In-Reply-To: <53247E31.7060002@ubuntu.com>
References: <1394812471-9693-1-git-send-email-psusi@ubuntu.com>
 <532417CA.1040300@gmail.com> <53247E31.7060002@ubuntu.com>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Date: Sat, 15 Mar 2014 17:25:35 +0100
Message-ID: <CAKgNAkjyXq0JVcJr4E+yie+r+2qbuFqm3=N589YNNVUvJOz6QQ@mail.gmail.com>
Subject: Re: [PATCH] readahead.2: don't claim the call blocks until all data
 has been read
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Phillip Susi <psusi@ubuntu.com>
Cc: linux-man <linux-man@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-ext4@vger.kernel.org, Corrado Zoccolo <czoccolo@gmail.com>, "Gregory P. Smith" <gps@google.com>, Zhu Yanhai <zhu.yanhai@gmail.com>

On Sat, Mar 15, 2014 at 5:22 PM, Phillip Susi <psusi@ubuntu.com> wrote:
> On 03/15/2014 05:05 AM, Michael Kerrisk (man-pages) wrote:
>>
>> I've tweaked your text a bit to make some details clearer (I hope):
>>
>>         readahead()  initiates  readahead  on a file so that subsequent
>>         reads from that file will, be satisfied from the cache, and not
>>         block  on  disk I/O (assuming the readahead was initiated early
>>         enough and that other activity on the system  did  not  in  the
>>         meantime flush pages from the cache).
>
>
> Slight grammatical error there: there's an extra comma in "file will, be".

Thanks. Fixed.

Otherwise okay, I assume?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 2BCA26B0074
	for <linux-mm@kvack.org>; Sat,  7 Jul 2012 22:29:14 -0400 (EDT)
Received: by obhx4 with SMTP id x4so16278690obh.14
        for <linux-mm@kvack.org>; Sat, 07 Jul 2012 19:29:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120707003819.GA2041@barrios>
References: <1341588521-17744-1-git-send-email-js1304@gmail.com>
	<20120706155920.GA7721@barrios>
	<CAAmzW4N+-xS65-NDJF2V9nzGDBTFC=20sZ8LJx5wCZ8=t7SpTQ@mail.gmail.com>
	<20120707003819.GA2041@barrios>
Date: Sun, 8 Jul 2012 11:29:13 +0900
Message-ID: <CAAmzW4OzJta03PhhRgJZrbqnwrSjVoCdpx+HBQ9wzwfKi7PFDQ@mail.gmail.com>
Subject: Re: [PATCH] mm: don't invoke __alloc_pages_direct_compact when order 0
From: JoonSoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: akpm@linux-foundation.org, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

>>
>> >> And in almost invoking case, order is 0, so return immediately.
>> >
>> > You can't make sure it.
>>
>> Okay.
>>
>> >>
>> >> Let's not invoke it when order 0
>> >
>> > Let's not ruin git blame.
>>
>> Hmm...
>> When I do git blame, I can't find anything related to this.
>
> I mean if we merge the pointless patch, it could be showed firstly instead of
> meaningful patch when we do git blame. It makes us bothering when we find blame-patch.

Oh... I see.

Thanks for comments.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

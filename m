Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f42.google.com (mail-yh0-f42.google.com [209.85.213.42])
	by kanga.kvack.org (Postfix) with ESMTP id 6893E6B008A
	for <linux-mm@kvack.org>; Tue, 26 Nov 2013 13:40:32 -0500 (EST)
Received: by mail-yh0-f42.google.com with SMTP id z6so4308076yhz.29
        for <linux-mm@kvack.org>; Tue, 26 Nov 2013 10:40:32 -0800 (PST)
Received: from mail-ob0-x231.google.com (mail-ob0-x231.google.com [2607:f8b0:4003:c01::231])
        by mx.google.com with ESMTPS id s46si24907038yhd.170.2013.11.26.10.40.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 26 Nov 2013 10:40:31 -0800 (PST)
Received: by mail-ob0-f177.google.com with SMTP id va2so6116536obc.8
        for <linux-mm@kvack.org>; Tue, 26 Nov 2013 10:40:30 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20131125162059.6989ef1680d43ed7a0a042ff@linux-foundation.org>
References: <alpine.DEB.2.02.1311121811310.29891@chino.kir.corp.google.com>
 <20131120141534.06ea091ca53b1dec60ace63d@linux-foundation.org>
 <CAHGf_=ooNHx=2HeUDGxrZFma-6YRvL42ViDMkSOqLOffk8MVsw@mail.gmail.com>
 <20131125123108.79c80eb59c2b1bc41c879d9e@linux-foundation.org>
 <5293E66F.8090000@jp.fujitsu.com> <20131125162059.6989ef1680d43ed7a0a042ff@linux-foundation.org>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Tue, 26 Nov 2013 13:40:09 -0500
Message-ID: <CAHGf_=pbFF8odDqh6jN2rPNh_FJhBqeo=Zf0GwSD-RbwWuopGg@mail.gmail.com>
Subject: Re: [patch -mm] mm, mempolicy: silence gcc warning
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Kees Cook <keescook@chromium.org>, "riel@redhat.com" <riel@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

>> diff --git a/include/linux/mempolicy.h b/include/linux/mempolicy.h
>> index 9fe426b..eee0597 100644
>> --- a/include/linux/mempolicy.h
>> +++ b/include/linux/mempolicy.h
>> @@ -309,6 +309,8 @@ static inline int mpol_parse_str(char *str, struct mempolicy **mpol)
>>
>>  static inline void mpol_to_str(char *buffer, int maxlen, struct mempolicy *pol)
>>  {
>> +     strncpy(buffer, "default", maxlen-1);
>> +     buffer[maxlen-1] = '\0';
>>  }
>>
>
> Well, as David said, BUILD_BUG() would be the preferred cleanup.  I'll
> stick one in there and see what the build bot has to say?

Sigh, I can't understand why you always prefer to increase maintenance annoying.
However up to you.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 3B5C46B002B
	for <linux-mm@kvack.org>; Fri,  7 Sep 2012 18:00:15 -0400 (EDT)
Received: by oagj6 with SMTP id j6so11329oag.14
        for <linux-mm@kvack.org>; Fri, 07 Sep 2012 15:00:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAAmzW4N8gqywrB1deA+Uv3oiO8L7DvCY1YdVNbZrsz+n6g9ThA@mail.gmail.com>
References: <1346885323-15689-1-git-send-email-elezegarcia@gmail.com>
	<1346885323-15689-5-git-send-email-elezegarcia@gmail.com>
	<CAAmzW4N8gqywrB1deA+Uv3oiO8L7DvCY1YdVNbZrsz+n6g9ThA@mail.gmail.com>
Date: Sat, 8 Sep 2012 07:00:14 +0900
Message-ID: <CAAmzW4N-gf6T+=2ZQgEoKDLgddhs0cu_NUip6Yu4Xf05xzkCnA@mail.gmail.com>
Subject: Re: [PATCH 5/5] mm, slob: Trace allocation failures consistently
From: JoonSoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ezequiel Garcia <elezegarcia@gmail.com>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>

>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>
> If we don't enable tracing, "unused variable warning" may occurs.

Oops, Sorry. Mistake.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

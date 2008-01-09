Received: by wa-out-1112.google.com with SMTP id m33so502810wag.8
        for <linux-mm@kvack.org>; Wed, 09 Jan 2008 07:31:33 -0800 (PST)
Message-ID: <4df4ef0c0801090731k505c9efds56fe38b7a284446@mail.gmail.com>
Date: Wed, 9 Jan 2008 18:31:33 +0300
From: "Anton Salikhmetov" <salikhmetov@gmail.com>
Subject: Re: [PATCH][RFC][BUG] updating the ctime and mtime time stamps in msync()
In-Reply-To: <9a8748490801090641s41a06c1era3764091f135567d@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <1199728459.26463.11.camel@codedot>
	 <4df4ef0c0801090332y345ccb67se98409edc65fd6bf@mail.gmail.com>
	 <9a8748490801090641s41a06c1era3764091f135567d@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jesper Juhl <jesper.juhl@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, joe@evalesco.com
List-ID: <linux-mm.kvack.org>

2008/1/9, Jesper Juhl <jesper.juhl@gmail.com>:
> I've only looked briefly at your patch but it seems resonable. I'll
> try to do some testing with it later.

Jesper, thank you very much for your answer!

In fact, I tested my change quite extensively using test cases for the
mmap() and msync() system calls from the LTP test suite. Please note
that I did mention that in my previous message:

>>>

Additionally, the test cases for the msync() system call from
the LTP test suite (msync01 - msync05, mmapstress01, mmapstress09,
and mmapstress10) successfully passed using the kernel
with the patch included into this email.

<<<

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

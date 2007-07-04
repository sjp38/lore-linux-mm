Received: by py-out-1112.google.com with SMTP id f31so1971132pyh
        for <linux-mm@kvack.org>; Tue, 03 Jul 2007 17:28:29 -0700 (PDT)
Message-ID: <7fe698080707031728j3a0091c9y73344a573667b65b@mail.gmail.com>
Date: Wed, 4 Jul 2007 09:28:29 +0900
From: "Dongjun Shin" <djshin90@gmail.com>
Subject: Re: vm/fs meetup in september?
In-Reply-To: <20070703122522.GB11942@lazybastard.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
References: <20070624042345.GB20033@wotan.suse.de>
	 <6934efce0706251708h7ab8d7dal6682def601a82073@mail.gmail.com>
	 <20070626060528.GA15134@infradead.org>
	 <6934efce0706261007x5e402eebvc528d2d39abd03a3@mail.gmail.com>
	 <20070630093243.GD22354@infradead.org>
	 <6934efce0707021044x44f51337ofa046c85e342a973@mail.gmail.com>
	 <20070702230418.GA5630@lazybastard.org>
	 <6934efce0707021746q133c62f5l803e5fa78b3535d9@mail.gmail.com>
	 <20070703122522.GB11942@lazybastard.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: =?ISO-8859-1?Q?J=F6rn_Engel?= <joern@logfs.org>
Cc: Jared Hulbert <jaredeh@gmail.com>, Christoph Hellwig <hch@infradead.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

I'd like to reference a paper titled "FASS : A Flash-Aware Swap System".
(http://kernel.kaist.ac.kr/~jinsoo/publication/iwssps05.pdf)

The paper describes a technique that uses NAND flash as a swap device
without FTL (Flash Translation Layer) or filesystem.

It is not related with XIP, however.

On 7/3/07, Jorn Engel <joern@logfs.org> wrote:
> On Mon, 2 July 2007 17:46:40 -0700, Jared Hulbert wrote:
> >
> > Right, the solution to swap problem is identical to the rw XIP
> > filesystem problem.    Jorn, that's why you're the self-appointed
> > subject matter expert!
>
> All right.  I'll try to make an important face whenever the subject
> comes up.
>
> Nick, do you have a problem if LogFS occupies two brainslots at the
> meeting?
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

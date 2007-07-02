Received: by nz-out-0506.google.com with SMTP id v1so699348nzb
        for <linux-mm@kvack.org>; Mon, 02 Jul 2007 10:44:01 -0700 (PDT)
Message-ID: <6934efce0707021044x44f51337ofa046c85e342a973@mail.gmail.com>
Date: Mon, 2 Jul 2007 10:44:00 -0700
From: "Jared Hulbert" <jaredeh@gmail.com>
Subject: Re: vm/fs meetup in september?
In-Reply-To: <20070630093243.GD22354@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070624042345.GB20033@wotan.suse.de>
	 <6934efce0706251708h7ab8d7dal6682def601a82073@mail.gmail.com>
	 <20070626060528.GA15134@infradead.org>
	 <6934efce0706261007x5e402eebvc528d2d39abd03a3@mail.gmail.com>
	 <20070630093243.GD22354@infradead.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>, Jared Hulbert <jaredeh@gmail.com>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> So what you mean is "swap on flash" ?  Defintively sounds like an
> interesting topic, although I'm not too sure it's all that
> filesystem-related.

Maybe not. Yet, it would be a very useful place to store data from a
file as a non-volatile page cache.

Also it is something that I believe would benefit from a VFS-like API.
 I mean there is a consistent interface a management layer like this
could use, yet the algorithms used to order the data and the interface
to the physical media may vary.  There is no single right way to do
the management layer, much like filesystems.

Given the page orientation of the current VFS seems to me like there
might be a nice way to use it for this purpose.

Or maybe the real experts on this stuff can tell me how wrong that is
and where it should go :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

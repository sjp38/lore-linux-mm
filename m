From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH]: Adding a counter in vma to indicate the number of physical_pages_backing it
Date: Tue, 13 Jun 2006 19:18:56 +0200
References: <787b0d920606122253o4f1a9e18x1ca49c3ce005696f@mail.gmail.com> <200606130756.52669.ak@suse.de> <1150218637.9576.73.camel@galaxy.corp.google.com>
In-Reply-To: <1150218637.9576.73.camel@galaxy.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200606131918.56772.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: rohitseth@google.com
Cc: Albert Cahalan <acahalan@gmail.com>, linux-kernel@vger.kernel.org, akpm@osdl.org, Linux-mm@kvack.org, arjan@infradead.org, jengelh@linux01.gwdg.de
List-ID: <linux-mm.kvack.org>

> Providing useful information about memory consumption is hardly
> debugging kludge. 

I strongly believe anything that shows virtual addresses is for debugging
only. If your monitoring systems needs to look at VMAs it is doing
something very wrong or trying to do something that shouldn't be 
in user space.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

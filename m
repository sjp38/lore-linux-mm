Message-ID: <3FFF1BF3.4050209@gmx.de>
Date: Fri, 09 Jan 2004 22:24:03 +0100
From: "Prakash K. Cheemplavam" <PrakashKC@gmx.de>
MIME-Version: 1.0
Subject: Re: 2.6.1-mm1
References: <20040109014003.3d925e54.akpm@osdl.org>	<3FFED73D.8020502@gmx.de> <20040109132038.2dfaef02.akpm@osdl.org>
In-Reply-To: <20040109132038.2dfaef02.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Bartlomiej Zolnierkiewicz <B.Zolnierkiewicz@elka.pw.edu.pl>
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> "Prakash K. Cheemplavam" <PrakashKC@gmx.de> wrote:
>>could it be that you took out /or forgot to insterst the work-around for 
>>nforce2+apic? At least I did a test with cpu disconnect on and booted 
> 
> I discussed it with Bart and he felt that it was not a good way of fixing
> the problem.  I'm not sure if he has a better fix in the works though..
> 
Yes, it is no good fix, but at least better than nothing...don't you agree?

Prakash
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

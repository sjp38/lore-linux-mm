Date: Fri, 9 Jan 2004 13:20:38 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: 2.6.1-mm1
Message-Id: <20040109132038.2dfaef02.akpm@osdl.org>
In-Reply-To: <3FFED73D.8020502@gmx.de>
References: <20040109014003.3d925e54.akpm@osdl.org>
	<3FFED73D.8020502@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Prakash K. Cheemplavam" <PrakashKC@gmx.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Bartlomiej Zolnierkiewicz <B.Zolnierkiewicz@elka.pw.edu.pl>
List-ID: <linux-mm.kvack.org>

"Prakash K. Cheemplavam" <PrakashKC@gmx.de> wrote:
>
> Hi,
> 
> could it be that you took out /or forgot to insterst the work-around for 
> nforce2+apic? At least I did a test with cpu disconnect on and booted 
> kernel and it hang. (I also couldn't find the work-around in the 
> sources.) I remember an earlier mm kernel had that workaround inside.
> 

I discussed it with Bart and he felt that it was not a good way of fixing
the problem.  I'm not sure if he has a better fix in the works though..
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

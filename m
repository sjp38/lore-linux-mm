Date: Fri, 23 May 2003 15:52:29 -0700
From: Andrew Morton <akpm@digeo.com>
Subject: Re: [PATCH] dirty bit clearing on s390.
Message-Id: <20030523155229.4106ac34.akpm@digeo.com>
In-Reply-To: <20030522112000.GA2597@mschwid3.boeblingen.de.ibm.com>
References: <20030522112000.GA2597@mschwid3.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: linux-mm@kvack.org, phillips@arcor.de
List-ID: <linux-mm.kvack.org>

Martin Schwidefsky <schwidefsky@de.ibm.com> wrote:
>
> I'd like to propose a small change in the common memory management that
> would enable s390 to get its dirty bits finally right. The change is a
> architecture hook in SetPageUptodate.

Having thought long and hard about this, yes, I don't really see anything
saner than just hooking into SetPageUptodate as you have done.

Just to be sure that I understand the issues here I'll cook up a new
changelog for this and run it by you, then submit it.

Thanks.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

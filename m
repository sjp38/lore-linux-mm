Message-ID: <57047.210.212.228.78.1043401756.webmail@mail.nitc.ac.in>
Date: Fri, 24 Jan 2003 15:19:16 +0530 (IST)
Subject: Re: your mail
From: "Anoop J." <cs99001@nitc.ac.in>
In-Reply-To: <Pine.LNX.4.44.0301240046580.10187-100000@dlang.diginsite.com>
References: <54208.210.212.228.78.1043398260.webmail@mail.nitc.ac.in>
        <Pine.LNX.4.44.0301240046580.10187-100000@dlang.diginsite.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: david.lang@digitalinsight.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

ok i shall put it in another way
since virtual indexing is a representation of the virtual memory,
it is possible for more multiple virtual addresses to represent the same
physical address.So the problem of aliasing occurs in the cache.Does page
coloring guarantee a unique mapping of physical address.If so how is the
maping from virtual to physical address



Thanks



> I think this is a case of the same tuerm being used for two different
> purposes. I don't know the use you are refering to.
>
> David Lang
>
>
>




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

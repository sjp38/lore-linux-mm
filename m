Subject: Consistent page aging....
References: <Pine.LNX.4.21.0107250416230.2823-100000@freak.distro.conectiva>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: 25 Jul 2001 04:10:48 -0600
In-Reply-To: <Pine.LNX.4.21.0107250416230.2823-100000@freak.distro.conectiva>
Message-ID: <m1n15tgvyv.fsf@frodo.biederman.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Marcelo Tosatti <marcelo@conectiva.com.br> writes:

> Sorry, Eric.
>
> The biggest 2.4 swapping bug is that we need to allocate swap space for a
> page to be able to age it. 

Well I guess biggest bug is a debatable title.  

> We had to be able to age pages without allocating swap space...

That sounds reasonable.  I haven't been over the aging code lately it
keeps changing.  You say this hasn't been fixed?  Looking... O.k. I
see what you are talking about.  

I don't see any technical reasons why we can't do this.  Doing it
without adding many extra special cases would require some thinking
but nothing fundamental says you can't have anonymous pages in the
active list.  You can't move mapped pages off of the active list
but this holds true anyway.

The only benefit this would bring is that after anonymous pages have
been converted to swappable pages they wouldn't start at the end of
the active_list.

I can see how this would be helpful, but unless you benchmark this
I don't see how this can as the biggest 2.4 swapping bug.

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

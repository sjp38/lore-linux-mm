Date: Fri, 22 Sep 2000 15:10:20 +0200
From: =?iso-8859-1?Q?Andr=E9_Dahlqvist?=
        <andre_dahlqvist@post.netlink.se>
Subject: Re: test9-pre5+t9p2-vmpatch VM deadlock during write-intensive workload
Message-ID: <20000922151020.A653@post.netlink.se>
References: <Pine.LNX.4.21.0009221131110.12532-200000@debella.aszi.sztaki.hu> <Pine.LNX.4.21.0009220725590.4442-200000@duckman.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <Pine.LNX.4.21.0009220725590.4442-200000@duckman.distro.conectiva>; from riel@conectiva.com.br on Fri, Sep 22, 2000 at 07:27:30AM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Molnar Ingo <mingo@debella.ikk.sztaki.hu>, "David S. Miller" <davem@redhat.com>, torvalds@transmeta.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Sep 22, 2000 at 07:27:30AM -0300, Rik van Riel wrote:

> Linus,
> 
> could you please include this patch in the next
> pre patch?

Rik,

I just had an oops with this patch applied. I ran into BUG at
buffer.c:730. The machine was not under load when the oops occured, I
was just reading e-mail in Mutt. I had to type the oops down by hand,
but I will provide ksymoops output soon if you need it.
-- 

// Andre
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

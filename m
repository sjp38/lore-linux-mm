Received: from digeo-nav01.digeo.com (digeo-nav01 [192.168.1.233])
	by packet.digeo.com (8.12.8/8.12.8) with SMTP id h2FBZfPu003940
	for <linux-mm@kvack.org>; Sat, 15 Mar 2003 03:35:41 -0800 (PST)
Date: Sat, 15 Mar 2003 03:35:50 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: 2.5.64-mm7
Message-Id: <20030315033550.32bc34cd.akpm@digeo.com>
In-Reply-To: <20030315112935.1841.qmail@linuxmail.org>
References: <20030315112935.1841.qmail@linuxmail.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Felipe Alfaro Solana <felipe_alfaro@linuxmail.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"Felipe Alfaro Solana" <felipe_alfaro@linuxmail.org> wrote:
>
> ----- Original Message ----- 
> From: Andrew Morton <akpm@digeo.com> 
> Date: 	Sat, 15 Mar 2003 01:17:58 -0800 
> To: linux-kernel@vger.kernel.org, linux-mm@kvack.org 
> Subject: 2.5.64-mm7 
>  
> > . Niggling bugs in the anticipatory scheduler are causing problems.  I've 
> >   reset the default to elevator=deadline until we get these fixed up. 
>  
> I haven't still experienced those bugs using mm6 and AS. 

Me either.

> Is there an easy way to reproduce them? 

If there was, they'd be fixed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>

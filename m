Message-ID: <20000831094802.D16191@saw.sw.com.sg>
Date: Thu, 31 Aug 2000 09:48:02 +0800
From: Andrey Savochkin <saw@saw.sw.com.sg>
Subject: Re: Question: memory management and QoS
References: <39ACB9E6.4914CB89@tuke.sk> <Pine.LNX.4.21.0008301237171.8164-100000@duckman.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.4.21.0008301237171.8164-100000@duckman.distro.conectiva>; from "Rik van Riel" on Wed, Aug 30, 2000 at 01:53:09PM
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>, Jan Astalos <astalos@tuke.sk>
Cc: Yuri Pudgorodsky <yur@asplinux.ru>, Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Aug 30, 2000 at 01:53:09PM -0300, Rik van Riel wrote:
> 
> Yes. If you sell resources to 10.000 users, there's usually no
> need to have 10.000 times the maximum per-user quota for every
> system resource.
> 
> Instead, you sell each user a guaranteed resource with the
> possibility to go up to a certain maximum. That way you can give
> your users a higher quality of service for much lower pricing,
> only with 99.999% guarantee instead of 100%.

That's exactly what I was speaking about and what I've been implementing..
Rik, thanks for saying it for me :-)

	Andrey
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

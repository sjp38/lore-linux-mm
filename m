Date: Mon, 28 Aug 2000 14:25:10 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Question: memory management and QoS
In-Reply-To: <39AA30AF.14C17C50@tuke.sk>
Message-ID: <Pine.LNX.4.21.0008281421180.18553-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jan Astalos <astalos@tuke.sk>
Cc: Andrey Savochkin <saw@saw.sw.com.sg>, linux-mm@kvack.org, Yuri Pudgorodsky <yur@asplinux.ru>
List-ID: <linux-mm.kvack.org>

On Mon, 28 Aug 2000, Jan Astalos wrote:

> I still claim that per user swapfiles will:
> - be _much_ more efficient in the sense of wasting disk space (saving money)
>   because it will teach users efficiently use their memory resources (if
>   user will waste the space inside it's own disk quota it will be his own
>   problem)
> - provide QoS on VM memory allocation to users (will guarantee amount of
>   available VM for user)
> - be able to improve _per_user_ performance of system (localizing performance
>   problems to users that caused them and reducing disk seek times)
> - shift the problem with OOM from system to user.

Do you have any reasons for this, or are you just asserting
them as if they were fact? ;)

I think we can achieve the same thing, with higher over-all
system performance, if we simply give each user a VM quota
and do the bookkeeping on a central swap area.

The reasons for this are multiple:
1) having one swap partition will reduce disk seeks
   (no matter how you put it, disk seeks are a _system_
   thing, not a per user thing)
2) not all users are logged in at the same time, so you
   can do a minimal form of overcomitting here (if you want)
3) you can easily give users _2_ VM quotas, a guaranteed one
   and a maximum one ... if a user goes over the guaranteed
   quota, processes can be killed in OOM situations
   (this allows each user to make their own choices wrt.
   overcommitment)

regards,


Rik
--
"What you're running that piece of shit Gnome?!?!"
       -- Miguel de Icaza, UKUUG 2000

http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

Date: Fri, 22 Sep 2000 11:14:02 +0200 (CEST)
From: Molnar Ingo <mingo@debella.aszi.sztaki.hu>
Subject: Re: test9-pre5+t9p2-vmpatch VM deadlock during write-intensive
 workload
In-Reply-To: <Pine.LNX.4.21.0009220603370.27435-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.21.0009221113130.12532-100000@debella.aszi.sztaki.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Molnar Ingo <mingo@debella.ikk.sztaki.hu>, "David S. Miller" <davem@redhat.com>, torvalds@transmeta.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 22 Sep 2000, Rik van Riel wrote:

>  894          if (current->need_resched && !(gfp_mask & __GFP_IO)) {
>  895                  __set_current_state(TASK_RUNNING);
>  896                  schedule();
>  897          }

> The idea was to not allow processes which have IO locks
> to schedule away, but as you can see, the check is 
> reversed ...

thanks ... sounds good. Will have this tested in about 15 mins.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

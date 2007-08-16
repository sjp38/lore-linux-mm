Date: Thu, 16 Aug 2007 08:43:13 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: Question:  cpuset_update_task_memory_state() and mmap_sem ???
Message-Id: <20070816084313.040cd2d9.pj@sgi.com>
In-Reply-To: <1187269951.5900.3.camel@localhost>
References: <1187033902.5592.33.camel@localhost>
	<20070815230626.dac091b1.pj@sgi.com>
	<1187269951.5900.3.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Lee, responding to pj:
> > ... would you like to propose a patch, nuking the phrase:
> > 
> >    and current->mm->mmap_sem
> > 
> > from that comment?
> 
> If that's the correct thing to do, sure.  Just wanted to check with you
> whether I was missing something.   

As best as I can tell, it's the correct thing to do, yes.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Message-ID: <418C03CD.2080501@sgi.com>
Date: Fri, 05 Nov 2004 16:50:53 -0600
From: Ray Bryant <raybry@sgi.com>
MIME-Version: 1.0
Subject: manual page migration, revisited...
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Hirokazu Takahashi <taka@valinux.co.jp>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Marcelo and Takahashi-san (and anyone else who would like to comment),

This is a little off topic, but this is as good of thread as any to start this 
discussion on.  Feel free to peel this off as a separate discussion thread 
asap if you like.

We have a requirement (for a potential customer) to do the following kind of
thing:

(1)  Suspend and swap out a running process so that the node where the process
      is running can be reassigned to a higher priority job.

(2)  Resume and swap back in those suspended jobs, restoring the original
      memory layout on the original nodes, or

(3)  Resume and swap back in those suspended jobs on a new set of nodes, with
      as similar topological layout as possible.  (It's also possible we may
      want to just move the jobs directly from one set of nodes to another
      without swapping them out first.

This is all in the context of a batch scheduler being used to run jobs on
a large paralell machine.

As I understand it, there are various patches floating around (including the
migration code that you are working on, the memory hotplug removal code, etc) 
that do parts of this, but I've had a little trouble piecing together the 
status of those various patches and where to get them.  (e. g. where do I get 
the latest migration cache code?).

There was also a thread in early April 2004 on this list about manual page
migration, I think, but I don't know where that went, if anywhere (that would
satisfy requirement 3.)

So the question I am asking, I guess, is where would you suggest we start on
an implementation for something like the above?  Which existing bits and 
peices can I pick up, if anything, from your migration cache work and or the
memory hotplug work, do you think?  Or, which patches should I be looking at
for ideas?

I'm not asking you to >>do<< this work, of course, I'm just trying to get a
start on the above and not unecessarily duplicate anyone's previous work in
this area.  Any pointers or advice would be greatly appeciated.
-- 
Best Regards,
Ray
-----------------------------------------------
                   Ray Bryant
512-453-9679 (work)         512-507-7807 (cell)
raybry@sgi.com             raybry@austin.rr.com
The box said: "Requires Windows 98 or better",
            so I installed Linux.
-----------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

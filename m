Received: from issun5.hti.com ([130.210.202.3]) by issun6.hti.com
          (Netscape Messaging Server 3.6)  with ESMTP id AAA5FAC
          for <linux-mm@kvack.org>; Wed, 2 May 2001 06:11:55 -0500
Message-ID: <3AEFF1D7.6090300@link.com>
Date: Wed, 02 May 2001 07:39:03 -0400
From: "Richard F Weber" <rfweber@link.com>
MIME-Version: 1.0
Subject: Re: About reading /proc/*/mem
References: <Pine.GSO.4.21.0105011231330.9771-100000@weyl.math.psu.edu>
Content-Type: multipart/alternative;
 boundary="------------020007040903030504000608"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexander Viro <viro@math.psu.edu>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--------------020007040903030504000608
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit



Alexander Viro wrote:

>
>On 1 May 2001, Eric W. Biederman wrote:
>
>>>Unfortunately, ptrace() probobally isn't going to allow me to do that.  
>>>So my next question is does opening /proc/*/mem force the child process 
>>>to stop on every interrupt (just like ptrace?)
>>>
>>
>>The not stopping the child should be the major difference between
>>/proc/*/mem and ptrace.
>>
>
>Could somebody tell me what would one do with data read from memory
>of process that is currently running?
>
After doing some digging around, I found this URL:   (Sorry, the 
original page at nsa seems to have disappeared).

http://www.google.com/search?q=cache:nsa.gov/selinux/slinux-200101020953/node57.html+access+physical+memory+/proc+/mem&hl=en

In any case, it indicates the the /proc/*/mem file can only be read by 
the process itself on the fly, or by a parent process that has stopped 
execution of the child via SIGSTOP.  So it seems so far that the 
behavior of /proc/*/mem is exactly the same as the behavior of ptrace in 
that it forces stoppage of execution in order to read memory.  
Bummer.(Or has this changed from v 2.2.x to v2.4.x?)

So how else can I access the process memory?  I'm wondering if it'd be 
feasible to hack the kernel to add an extra ptrace_nostop() fn that 
would allow ptracing without forcing a stop in the process.  I'd really 
rather not have to hack the kernel unless I really have to though.

My second thought is again going back to finding the translation of 
where the process physically lives in the virtual memory itself.  So 
this way I can just go and directly look at the memory of the process.  
But then this runs into problems as to finding where that process lives, 
and being told my thoughts on this are totally wrong.

I suppose the question is I know the process exists, I know the process 
is pinned into memory so it can't get swapped out, I just need to know 
how to translate the process's virtual address of 0x080495998 to some 
chunk of physical memory, and then take a look at it.

Thanks.

--Rich

--------------020007040903030504000608
Content-Type: text/html; charset=us-ascii
Content-Transfer-Encoding: 7bit

<html><head></head><body><br>
<br>
Alexander Viro wrote:<br>
<blockquote type="cite" cite="mid:Pine.GSO.4.21.0105011231330.9771-100000@weyl.math.psu.edu"><pre wrap=""><br>On 1 May 2001, Eric W. Biederman wrote:<br><br></pre>
  <blockquote type="cite"><blockquote type="cite"><pre wrap="">Unfortunately, ptrace() probobally isn't going to allow me to do that.  <br>So my next question is does opening /proc/*/mem force the child process <br>to stop on every interrupt (just like ptrace?)<br></pre></blockquote><pre wrap=""><br>The not stopping the child should be the major difference between<br>/proc/*/mem and ptrace.<br></pre></blockquote>
      <pre wrap=""><!----><br>Could somebody tell me what would one do with data read from memory<br>of process that is currently running?<br><br></pre>
      </blockquote>
After doing some digging around, I found this URL: &nbsp; (Sorry, the original page at nsa seems to have disappeared).<br>
      <br>
<a class="moz-txt-link-freetext" href="http://www.google.com/search?q=cache:nsa.gov/selinux/slinux-200101020953/node57.html+access+physical+memory+/proc+/mem&hl=en">http://www.google.com/search?q=cache:nsa.gov/selinux/slinux-200101020953/node57.html+access+physical+memory+/proc+/mem&amp;hl=en</a><br>
      <br>
  In any case, it indicates the the /proc/*/mem file can only be read by
the process itself on the fly, or by a parent process that has stopped execution
of the child via SIGSTOP.&nbsp; So it seems so far that the behavior of /proc/*/mem
is exactly the same as the behavior of ptrace in that it forces stoppage
of execution in order to read memory.&nbsp; Bummer.(Or has this changed from v
2.2.x to v2.4.x?)<br>
      <br>
So how else can I access the process memory?&nbsp; I'm wondering if it'd be feasible
to hack the kernel to add an extra ptrace_nostop() fn that would allow ptracing
without forcing a stop in the process.&nbsp; I'd really rather not have to hack
the kernel unless I really have to though.<br>
      <br>
My second thought is again going back to finding the translation of where
the process physically lives in the virtual memory itself.&nbsp; So this way I
can just go and directly look at the memory of the process.&nbsp; But then this
runs into problems as to finding where that process lives, and being told
my thoughts on this are totally wrong.<br>
      <br>
I suppose the question is I know the process exists, I know the process is
pinned into memory so it can't get swapped out, I just need to know how to
translate the process's virtual address of 0x080495998 to some chunk of physical
memory, and then take a look at it.<br>
      <br>
Thanks.<br>
      <br>
--Rich<br>
</body></html>
--------------020007040903030504000608--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

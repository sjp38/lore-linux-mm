Received: from issun5.hti.com ([130.210.202.3]) by issun6.hti.com
          (Netscape Messaging Server 3.6)  with ESMTP id AAA6AE3
          for <linux-mm@kvack.org>; Tue, 1 May 2001 11:26:28 -0500
Message-ID: <3AEEEA09.7000301@link.com>
Date: Tue, 01 May 2001 12:53:29 -0400
From: "Richard F Weber" <rfweber@link.com>
MIME-Version: 1.0
Subject: Re: About reading /proc/*/mem
References: <3AEEBB22.9030801@link.com> <m1oftdozsi.fsf@frodo.biederman.org>
Content-Type: multipart/alternative;
 boundary="------------030309050001020607090802"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--------------030309050001020607090802
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit


Eric W. Biederman wrote:

>"Richard F Weber" <rfweber@link.com> writes:
>
>>Ok, so as a rehash, the ptrace & open(),lseek() on /proc/*/mem should 
>>both work about the same.  After a lot of struggling, I've gotten the 
>>ptrace to work right & spit out the data I want/need.  However there is 
>>one small problem, SIGSTOP.
>>
>>ptrace() appears to set up the child process to do a SIGSTOP whenever 
>>any interrupt is received.  Which is kind of a bad thing for what I'm 
>>looking to do.  I guess I'm trying to write a non-intrusive debugger 
>>that can be used to view static variables stored in the heap of an 
>>application.
>>
>>On other OS's, this can be done just by popping open /proc/*/mem, and 
>>reading the data as needed, allowing the child process to continue 
>>processing away as if nothing is going on.  I'm looking to do the same 
>>sort of task under Linux. 
>>
>>Unfortunately, ptrace() probobally isn't going to allow me to do that.  
>>So my next question is does opening /proc/*/mem force the child process 
>>to stop on every interrupt (just like ptrace?)
>>
>
>
>The not stopping the child should be the major difference between
>/proc/*/mem and ptrace.
>
See this is where I start seeming to have problems.  I can open 
/proc/*/mem & lseek, but reads come back as "No such process".  However, 
if I first do a ptrace(PTRACE_ATTACH), then I can read the data, but the 
process stops.  I've kind of dug through the sys_ptrace() code under 
/usr/src/linux/arch/i386/kernel/ptrace.c, and can see and understand 
generally what it's doing, but that's getting into serious kernel-land 
stuff.  I wouldn't expect it to be this difficult to just open up 
another processes /proc/*/mem file to read data from.

Is there something obvious I'm missing?  It seems to keep pointing back 
to ptrace & /proc/*/mem are very closely related (ie: the same) 
including stopping of the child.

Thanks.

--Rich

--------------030309050001020607090802
Content-Type: text/html; charset=us-ascii
Content-Transfer-Encoding: 7bit

<html><head></head><body><br>
Eric W. Biederman wrote:<br>
<blockquote type="cite" cite="mid:m1oftdozsi.fsf@frodo.biederman.org"><pre wrap="">"Richard F Weber" <a class="moz-txt-link-rfc2396E" href="mailto:rfweber@link.com">&lt;rfweber@link.com&gt;</a> writes:<br><br></pre>
  <blockquote type="cite"><pre wrap="">Ok, so as a rehash, the ptrace &amp; open(),lseek() on /proc/*/mem should <br>both work about the same.  After a lot of struggling, I've gotten the <br>ptrace to work right &amp; spit out the data I want/need.  However there is <br>one small problem, SIGSTOP.<br><br>ptrace() appears to set up the child process to do a SIGSTOP whenever <br>any interrupt is received.  Which is kind of a bad thing for what I'm <br>looking to do.  I guess I'm trying to write a non-intrusive debugger <br>that can be used to view static variables stored in the heap of an <br>application.<br><br>On other OS's, this can be done just by popping open /proc/*/mem, and <br>reading the data as needed, allowing the child process to continue <br>processing away as if nothing is going on.  I'm looking to do the same <br>sort of task under Linux. <br><br>Unfortunately, ptrace() probobally isn't going to allow me to do that.  <br>So my next question is does opening /proc/*/mem force the child process <br>to stop on every interrupt (just like ptrace?)<br></pre></blockquote>
    <pre wrap=""><!----><br><br>The not stopping the child should be the major difference between<br>/proc/*/mem and ptrace.<br><br></pre>
    </blockquote>
See this is where I start seeming to have problems.&nbsp; I can open /proc/*/mem
&amp; lseek, but reads come back as "No such process".&nbsp; However, if I first
do a ptrace(PTRACE_ATTACH), then I can read the data, but the process stops.&nbsp;
I've kind of dug through the sys_ptrace() code under /usr/src/linux/arch/i386/kernel/ptrace.c,
and can see and understand generally what it's doing, but that's getting
into serious kernel-land stuff.&nbsp; I wouldn't expect it to be this difficult
to just open up another processes /proc/*/mem file to read data from.<br>
    <br>
Is there something obvious I'm missing?&nbsp; It seems to keep pointing back to
ptrace &amp; /proc/*/mem are very closely related (ie: the same) including
stopping of the child.<br>
    <br>
Thanks.<br>
    <br>
--Rich<br>
</body></html>
--------------030309050001020607090802--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

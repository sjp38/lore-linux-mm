Received: from issun5.hti.com ([130.210.202.3]) by issun6.hti.com
          (Netscape Messaging Server 3.6)  with ESMTP id AAA5AAC
          for <linux-mm@kvack.org>; Mon, 30 Apr 2001 13:46:19 -0500
Message-ID: <3AEDB946.2060708@link.com>
Date: Mon, 30 Apr 2001 15:13:10 -0400
From: "Richard F Weber" <rfweber@link.com>
MIME-Version: 1.0
Subject: Re: Hopefully a simple question on /proc/pid/mem
References: <3AEDAC29.40309@link.com> <20010430195007.F26638@redhat.com>
Content-Type: multipart/alternative;
 boundary="------------020008010705030403010102"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--------------020008010705030403010102
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Well ptrace connects, but getting the data out is what seems to be the 
really tough part.  I've seen some examples of opening up the 
/proc/pid/mem file just using the

.................
int addr=0x<some memory address>;
char buffer[255];

proc_file=open ("/proc/pid/mem",O_RDONLY);
lseek(proc_file,addr,SEEK_SET);
read (proc_file,buffer,sizeof(buffer));
.................

But then the system complains about "No Such Process".  I know the 
process is working and this fails as both the user running the target 
process, as well as root.  I'm also using a 2.2.16 kernel stock from 
RH7.0 (but I didn't think that would really matter). I don't need 
register access (at least not yet).

The only other thing I'm wondering is if there is some permission that 
must be granted by the target process, but I've already tried the 
ptrace(PTRACE_TRACEME) line.

Thanks.

--Rich

Stephen C. Tweedie wrote:

>Hi,
>
>On Mon, Apr 30, 2001 at 02:17:13PM -0400, Richard F Weber wrote:
>
>>Hopefully this is a simple question.  I'm trying to work on an external 
>>debugger that can bind to an external process, and open up memory 
>>locations on the heap to allow reading of data.
>>
>>Now I've tried using ptrace(), mmap() & lseek/read all with no success.  
>>The closest I've been able to get is to use ptrace() to do an attach to 
>>the target process, but couldn't read much of anything from it.
>>
>
>ptrace is what other debuggers use.  It really ought to work.
>
>Cheers,
> Stephen
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux.eu.org/Linux-MM/
>


--------------020008010705030403010102
Content-Type: text/html; charset=us-ascii
Content-Transfer-Encoding: 7bit

<html><head></head><body>Well ptrace connects, but getting the data out is
what seems to be the really tough part.&nbsp; I've seen some examples of opening
up the /proc/pid/mem file just using the <br>
<br>
.................<br>
int addr=0x&lt;some memory address&gt;;<br>
char buffer[255];<br>
<br>
proc_file=open ("/proc/pid/mem",O_RDONLY);<br>
lseek(proc_file,addr,SEEK_SET);<br>
read (proc_file,buffer,sizeof(buffer));<br>
.................<br>
<br>
But then the system complains about "No Such Process".&nbsp; I know the process
is working and this fails as both the user running the target process, as
well as root.&nbsp; I'm also using a 2.2.16 kernel stock from RH7.0 (but I didn't
think that would really matter).  I don't need register access (at least not yet).<br>
<br>
The only other thing I'm wondering is if there is some permission that must
be granted by the target process, but I've already tried the ptrace(PTRACE_TRACEME)
line.<br>
<br>
Thanks.<br>
<br>
--Rich<br>
<br>
Stephen C. Tweedie wrote:<br>
<blockquote type="cite" cite="mid:20010430195007.F26638@redhat.com"><pre wrap="">Hi,<br><br>On Mon, Apr 30, 2001 at 02:17:13PM -0400, Richard F Weber wrote:<br></pre>
  <blockquote type="cite"><pre wrap="">Hopefully this is a simple question.  I'm trying to work on an external <br>debugger that can bind to an external process, and open up memory <br>locations on the heap to allow reading of data.<br><br>Now I've tried using ptrace(), mmap() &amp; lseek/read all with no success.  <br>The closest I've been able to get is to use ptrace() to do an attach to <br>the target process, but couldn't read much of anything from it.<br></pre></blockquote>
    <pre wrap=""><!----><br>ptrace is what other debuggers use.  It really ought to work.<br><br>Cheers,<br> Stephen<br>--<br>To unsubscribe, send a message with 'unsubscribe linux-mm' in<br>the body to <a class="moz-txt-link-abbreviated" href="mailto:majordomo@kvack.org">majordomo@kvack.org</a>.  For more info on Linux MM,<br>see: <a class="moz-txt-link-freetext" href="http://www.linux.eu.org/Linux-MM/">http://www.linux.eu.org/Linux-MM/</a><br></pre>
    </blockquote>
    <br>
</body></html>
--------------020008010705030403010102--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

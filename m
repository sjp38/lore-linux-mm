Received: from issun5.hti.com ([130.210.202.3]) by issun6.hti.com
          (Netscape Messaging Server 3.6)  with ESMTP id AAA6C60
          for <linux-mm@kvack.org>; Tue, 1 May 2001 11:36:04 -0500
Message-ID: <3AEEEC48.80709@link.com>
Date: Tue, 01 May 2001 13:03:04 -0400
From: "Richard F Weber" <rfweber@link.com>
MIME-Version: 1.0
Subject: Re: About reading /proc/*/mem
References: <Pine.GSO.4.21.0105011231330.9771-100000@weyl.math.psu.edu>
Content-Type: multipart/alternative;
 boundary="------------090203020208030401040307"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexander Viro <viro@math.psu.edu>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--------------090203020208030401040307
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

The main thing I'm looking to do is examine data that's part of a 
real-time process.  The process's execution can't be interrupted, 
otherwise it makes debugging it inaccurate.  The applications is 
certainly not looking to see every line of code get executed, but rather 
have a real-time monitor of a symbol as it gets modified.  Now 
viewing/selecting the symbol is done through a combination of nm's & a 
console based util (hopefully GTK Based in the future).  Other 
applications include recording this data to disk for later playback & 
analysis.

Now the next logical step would be to create a debug module in the RT 
system itself that dumps out the values we care about.  The problem with 
this is we are looking at a lot of legacy code (done in fortran, C & 
Ada) as well as tons of variables.  By peeking at the memory on the fly 
we can dynamically decide which values are important for this run, 
without having to record all possible data to the disk (which in itself 
would be quite painful since disk accesses would make debugging again 
difficult).

Granted, it's probobally not a very popular application, but it's still 
one which is present in many of the Big Unixes, and so far has me 
stumped as to how to get it working correctly under Linux.

--Rich

Alexander Viro wrote:

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
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux.eu.org/Linux-MM/
>


--------------090203020208030401040307
Content-Type: text/html; charset=us-ascii
Content-Transfer-Encoding: 7bit

<html><head></head><body>The main thing I'm looking to do is examine data
that's part of a real-time process.&nbsp; The process's execution can't be interrupted,
otherwise it makes debugging it inaccurate.&nbsp; The applications is certainly
not looking to see every line of code get executed, but rather have a real-time
monitor of a symbol as it gets modified.&nbsp; Now viewing/selecting the symbol
is done through a combination of nm's &amp; a console based util (hopefully
GTK Based in the future).&nbsp; Other applications include recording this data
to disk for later playback &amp; analysis.<br>
<br>
Now the next logical step would be to create a debug module in the RT system
itself that dumps out the values we care about.&nbsp; The problem with this is
we are looking at a lot of legacy code (done in fortran, C &amp; Ada) as
well as tons of variables.&nbsp; By peeking at the memory on the fly we can dynamically
decide which values are important for this run, without having to record
all possible data to the disk (which in itself would be quite painful since
disk accesses would make debugging again difficult).<br>
<br>
Granted, it's probobally not a very popular application, but it's still one
which is present in many of the Big Unixes, and so far has me stumped as
to how to get it working correctly under Linux.<br>
<br>
--Rich<br>
<br>
Alexander Viro wrote:<br>
<blockquote type="cite" cite="mid:Pine.GSO.4.21.0105011231330.9771-100000@weyl.math.psu.edu"><pre wrap="">On 1 May 2001, Eric W. Biederman wrote:<br><br></pre>
  <blockquote type="cite"><blockquote type="cite"><pre wrap="">Unfortunately, ptrace() probobally isn't going to allow me to do that.  <br>So my next question is does opening /proc/*/mem force the child process <br>to stop on every interrupt (just like ptrace?)<br></pre></blockquote><pre wrap=""><br>The not stopping the child should be the major difference between<br>/proc/*/mem and ptrace.<br></pre></blockquote>
      <pre wrap=""><!----><br>Could somebody tell me what would one do with data read from memory<br>of process that is currently running?<br><br>--<br>To unsubscribe, send a message with 'unsubscribe linux-mm' in<br>the body to <a class="moz-txt-link-abbreviated" href="mailto:majordomo@kvack.org">majordomo@kvack.org</a>.  For more info on Linux MM,<br>see: <a class="moz-txt-link-freetext" href="http://www.linux.eu.org/Linux-MM/">http://www.linux.eu.org/Linux-MM/</a><br></pre>
      </blockquote>
      <br>
</body></html>
--------------090203020208030401040307--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

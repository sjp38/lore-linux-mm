Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 4086D8D0001
	for <linux-mm@kvack.org>; Tue,  2 Nov 2010 07:34:19 -0400 (EDT)
Message-ID: <4CCFF1BA.1010206@redhat.com>
Date: Tue, 02 Nov 2010 07:10:50 -0400
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] Cross Memory Attach
References: <20100915104855.41de3ebf@lilo>	<4C90A6C7.9050607@redhat.com>	<AANLkTi=rmUUPCm212Sju-wW==5cT4eqqU+FEP_hX-Z_y@mail.gmail.com>	<20100916104819.36d10acb@lilo>	<4C91E2CC.9040709@redhat.com> <20101102140710.5f2a6557@lilo>
In-Reply-To: <20101102140710.5f2a6557@lilo>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christopher Yeoh <cyeoh@au1.ibm.com>
Cc: Bryan Donlan <bdonlan@gmail.com>, linux-kernel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

  On 11/01/2010 11:37 PM, Christopher Yeoh wrote:
> >
> >  You could have each process open /proc/self/mem and pass the fd using
> >  SCM_RIGHTS.
> >
> >  That eliminates a race; with copy_to_process(), by the time the pid
> >  is looked up it might designate a different process.
>
> Just to revive an old thread (I've been on holidays), but this doesn't
> work either. the ptrace check is done by mem_read (eg on each read) so
> even if you do pass the fd using SCM_RIGHTS, reads on the fd still
> fail.
>
> So unless there's good reason to believe that the ptrace permission
> check is no longer needed, the /proc/pid/mem interface doesn't seem to
> be an option for what we want to do.
>

Perhaps move the check to open().  I can understand the desire to avoid 
letting random processes peek each other's memory, but once a process 
has opened its own /proc/self/mem and explicitly passed it to another, 
we should allow it.

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

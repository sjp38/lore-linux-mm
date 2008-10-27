Message-ID: <490637D8.4080404@cs.columbia.edu>
Date: Mon, 27 Oct 2008 17:51:20 -0400
From: Oren Laadan <orenl@cs.columbia.edu>
MIME-Version: 1.0
Subject: Re: [RFC v7][PATCH 2/9] General infrastructure for	checkpoint	restart
References: <1224481237-4892-1-git-send-email-orenl@cs.columbia.edu>	 <1224481237-4892-3-git-send-email-orenl@cs.columbia.edu>	 <20081021124130.a002e838.akpm@linux-foundation.org>	 <20081021202410.GA10423@us.ibm.com>	<48FE82DF.6030005@cs.columbia.edu>	 <20081022152804.GA23821@us.ibm.com>	<48FF4EB2.5060206@cs.columbia.edu>	 <87tzayh27r.wl%peter@chubb.wattle.id.au> <49059FED.4030202@cs.columbia.edu>	 <1225125752.12673.79.camel@nimitz> <4905F648.4030402@cs.columbia.edu> <1225140705.5115.40.camel@enoch>
In-Reply-To: <1225140705.5115.40.camel@enoch>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Helsley <matthltc@us.ibm.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-api@vger.kernel.org, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tglx@linutronix.de, viro@zeniv.linux.org.uk, hpa@zytor.com, mingo@elte.hu, torvalds@linux-foundation.org, Peter Chubb <peterc@gelato.unsw.edu.au>
List-ID: <linux-mm.kvack.org>


Matt Helsley wrote:
> On Mon, 2008-10-27 at 13:11 -0400, Oren Laadan wrote:
>> Dave Hansen wrote:
>>> On Mon, 2008-10-27 at 07:03 -0400, Oren Laadan wrote:
>>>>> In our implementation, we simply refused to checkpoint setid
>>>> programs.
>>>>
>>>> True. And this works very well for HPC applications.
>>>>
>>>> However, it doesn't work so well for server applications, for
>>>> instance.
>>>>
>>>> Also, you could use file system snapshotting to ensure that the file
>>>> system view does not change, and still face the same issue.
>>>>
>>>> So I'm perfectly ok with deferring this discussion to a later time :)
>>> Oren, is this a good place to stick a process_deny_checkpoint()?  Both
>>> so we refuse to checkpoint, and document this as something that has to
>>> be addressed later?
>> why refuse to checkpoint ?
> 
> 	If most setuid programs hold privileged resources for extended periods
> of time after dropping privileges then it seems like a good idea to
> refuse to checkpoint. Restart of those programs would be quite
> unreliable unless/until we find a nice solution.
> 
>> if I'm root, and I want to checkpoint, and later restart, my sshd server
>> (assuming we support listening sockets) - then why not ?
>> we can just let it be, and have the restart fail (if it isn't root that
>> does the restart); perhaps add something like warn_checkpoint() (similar
>> to deny, but only warns) ?
> 
> 	How will folks not specializing in checkpoint/restart know when to use
> this as opposed to deny?
> 
> 	Instead, how about a flag to sys_checkpoint() -- DO_RISKY_CHECKPOINT --
> which checkpoints despite !may_checkpoint?

I also agree with Matt - so we have a quorum :)

so just to clarify: sys_checkpoint() is to fail (with what error ?) if the
deny-checkpoint test fails.

however, if the user is risky, she can specify CR_CHECKPOINT_RISKY to force
an attempt to checkpoint as is.

does this sound right ?

Oren.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

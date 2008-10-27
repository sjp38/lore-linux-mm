Message-ID: <4905F648.4030402@cs.columbia.edu>
Date: Mon, 27 Oct 2008 13:11:36 -0400
From: Oren Laadan <orenl@cs.columbia.edu>
MIME-Version: 1.0
Subject: Re: [RFC v7][PATCH 2/9] General infrastructure for checkpoint	restart
References: <1224481237-4892-1-git-send-email-orenl@cs.columbia.edu>	 <1224481237-4892-3-git-send-email-orenl@cs.columbia.edu>	 <20081021124130.a002e838.akpm@linux-foundation.org>	 <20081021202410.GA10423@us.ibm.com>	<48FE82DF.6030005@cs.columbia.edu>	 <20081022152804.GA23821@us.ibm.com>	<48FF4EB2.5060206@cs.columbia.edu>	 <87tzayh27r.wl%peter@chubb.wattle.id.au> <49059FED.4030202@cs.columbia.edu> <1225125752.12673.79.camel@nimitz>
In-Reply-To: <1225125752.12673.79.camel@nimitz>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Peter Chubb <peterc@gelato.unsw.edu.au>, linux-api@vger.kernel.org, containers@lists.linux-foundation.org, mingo@elte.hu, linux-kernel@vger.kernel.org, linux-mm@kvack.org, viro@zeniv.linux.org.uk, hpa@zytor.com, Andrew Morton <akpm@linux-foundation.org>, torvalds@linux-foundation.org, tglx@linutronix.de
List-ID: <linux-mm.kvack.org>

Dave Hansen wrote:
> On Mon, 2008-10-27 at 07:03 -0400, Oren Laadan wrote:
>>> In our implementation, we simply refused to checkpoint setid
>> programs.
>>
>> True. And this works very well for HPC applications.
>>
>> However, it doesn't work so well for server applications, for
>> instance.
>>
>> Also, you could use file system snapshotting to ensure that the file
>> system view does not change, and still face the same issue.
>>
>> So I'm perfectly ok with deferring this discussion to a later time :)
> 
> Oren, is this a good place to stick a process_deny_checkpoint()?  Both
> so we refuse to checkpoint, and document this as something that has to
> be addressed later?

why refuse to checkpoint ?

if I'm root, and I want to checkpoint, and later restart, my sshd server
(assuming we support listening sockets) - then why not ?

we can just let it be, and have the restart fail (if it isn't root that
does the restart); perhaps add something like warn_checkpoint() (similar
to deny, but only warns) ?

Oren.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

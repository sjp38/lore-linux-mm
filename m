Date: Tue, 17 Aug 2004 23:18:30 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: arch_get_unmapped_area_topdown vs stack reservations
Message-ID: <259380000.1092809909@[10.10.2.4]>
In-Reply-To: <20040818061121.GB21740@devserv.devel.redhat.com>
References: <170170000.1092781114@flay> <20040818061121.GB21740@devserv.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Arjan van de Ven <arjanv@redhat.com>
Cc: Ingo Molnar <mingo@elte.hu>, linux-mm mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

--Arjan van de Ven <arjanv@redhat.com> wrote (on Wednesday, August 18, 2004 08:11:21 +0200):

> On Tue, Aug 17, 2004 at 03:18:34PM -0700, Martin J. Bligh wrote:
>> I worry that the current code will allow us to intrude into the 
>> reserved stack space with a vma allocation if it's requested at
>> an address too high up. One could argue that they got what they
>> asked for ... but not sure we should be letting them do that?
> 
> well even the non-flexmmap code allows this...

Yeah, wasn't meant as a criticism of the new layout, just a general
improvement, perhaps.

> what is the problem ?

Just that if they allocate right up to the stack, we'll go boom shortly
afterwards. I guess the question is ... what exactly are the rules
for stack space reservations?

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

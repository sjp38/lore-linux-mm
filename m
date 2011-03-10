Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1B67A8D0039
	for <linux-mm@kvack.org>; Thu, 10 Mar 2011 12:23:29 -0500 (EST)
References: <1299630721-4337-1-git-send-email-wilsons@start.ca> <20110310160032.GA20504@alboin.amr.corp.intel.com> <20110310163809.GA20675@alboin.amr.corp.intel.com> <20110310165414.GA6431@fibrous.localdomain>
In-Reply-To: <20110310165414.GA6431@fibrous.localdomain>
MIME-Version: 1.0
Content-Type: multipart/alternative; boundary="----V09616JKR7L2B0NB8391YYHI8HKF8V"
Subject: =?US-ASCII?Q?Re=3A_=5BPATCH_0/5=5D_make_*=5Fgate=5Fvma_accep?= =?US-ASCII?Q?t_mm=5Fstruct_instead_of=09task=5Fstruct_II?=
From: "H. Peter Anvin" <hpa@zytor.com>
Date: Thu, 10 Mar 2011 09:22:48 -0800
Message-ID: <37e280c3-7f6b-4f1e-9589-68f4a67e4c0a@email.android.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Wilson <wilsons@start.ca>, Andi Kleen <ak@linux.intel.com>
Cc: x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux390@de.ibm.com, Paul Mundt <lethal@linux-sh.org>, Michel Lespinasse <walken@google.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

------V09616JKR7L2B0NB8391YYHI8HKF8V
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit

Sorry... I confused them too. It's TS_COMPAT which is problematic.
-- 
Sent from my mobile phone. Please pardon any lack of formatting.

Stephen Wilson <wilsons@start.ca> wrote:

On Thu, Mar 10, 2011 at 08:38:09AM -0800, Andi Kleen wrote: > On Thu, Mar 10, 2011 at 08:00:32AM -0800, Andi Kleen wrote: > > On Tue, Mar 08, 2011 at 07:31:56PM -0500, Stephen Wilson wrote: > > > The only architecture this change impacts in any significant way is x86_64. > > > The principle change on that architecture is to mirror TIF_IA32 via > > > a new flag in mm_context_t. > > > > The problem is -- you're adding a likely cache miss on mm_struct for > > every 32bit compat syscall now, even if they don't need mm_struct > > currently (and a lot of them do not) Unless there's a very good > > justification to make up for this performance issue elsewhere > > (including numbers) this seems like a bad idea. > > Hmm I see you're only setting it on exec time actually on rereading > the patches. I thought you were changing TS_COMPAT which is in > the syscall path. > > Never mind. I have no problems with doing such a change on exec > time. OK. Great! Does this mean I have your ACK'e!
 d by or
reviewed by? Thanks for taking a look! -- steve 


------V09616JKR7L2B0NB8391YYHI8HKF8V
Content-Type: text/html;
 charset=utf-8
Content-Transfer-Encoding: 8bit

<html><head></head><body>Sorry... I confused them too.  It&#39;s TS_COMPAT which is problematic.<br>
-- <br>
Sent from my mobile phone.  Please pardon any lack of formatting.<br><br><div class="gmail_quote">Stephen Wilson &lt;wilsons@start.ca&gt; wrote:<blockquote class="gmail_quote" style="margin: 0pt 0pt 0pt 0.8ex; border-left: 1px solid rgb(204, 204, 204); padding-left: 1ex;">
<div style="white-space: pre-wrap; word-wrap:break-word; ">
On Thu, Mar 10, 2011 at 08:38:09AM -0800, Andi Kleen wrote:
&gt; On Thu, Mar 10, 2011 at 08:00:32AM -0800, Andi Kleen wrote:
&gt; &gt; On Tue, Mar 08, 2011 at 07:31:56PM -0500, Stephen Wilson wrote:
&gt; &gt; &gt; The only architecture this change impacts in any significant way is x86_64.
&gt; &gt; &gt; The principle change on that architecture is to mirror TIF_IA32 via
&gt; &gt; &gt; a new flag in mm_context_t. 
&gt; &gt; 
&gt; &gt; The problem is -- you're adding a likely cache miss on mm_struct for
&gt; &gt; every 32bit compat syscall now, even if they don't need mm_struct
&gt; &gt; currently (and a lot of them do not) Unless there's a very good
&gt; &gt; justification to make up for this performance issue elsewhere
&gt; &gt; (including numbers) this seems like a bad idea.
&gt; 
&gt; Hmm I see you're only setting it on exec time actually on rereading
&gt; the patches. I thought you were changing TS_COMPAT which is in
&gt; the syscall path.
&gt; 
&gt; Never mind.  I have no problems with doing such a change on exec
&gt; time.

OK.  Great!  Does this mean I have your ACK'ed by or reviewed by?


Thanks for taking a look!

-- 
steve

</div></blockquote></div></body></html>
------V09616JKR7L2B0NB8391YYHI8HKF8V--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Wed, 16 Jul 2003 08:09:53 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: 2.6.0-test1-mm1
Message-ID: <20030716150953.GL15452@holomorphy.com>
References: <20030715225608.0d3bff77.akpm@osdl.org> <20030716104448.GC25869@ip68-4-255-84.oc.oc.cox.net> <20030716035848.560674ac.akpm@osdl.org> <20030716122454.GJ15452@holomorphy.com> <20030716143221.GD25829@ip68-4-255-84.oc.oc.cox.net> <20030716144155.GK15452@holomorphy.com> <20030716150207.GE25829@ip68-4-255-84.oc.oc.cox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030716150207.GE25829@ip68-4-255-84.oc.oc.cox.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Barry K. Nathan" <barryn@pobox.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 16, 2003 at 07:41:55AM -0700, William Lee Irwin III wrote:
>> Oh, well that won't fly; it effectively isn't a constant initializer.
>> I'll see what can be rammed past gcc. We're shooting for something
>> with array element 0 equal to 0x1UL and all others 0.

On Wed, Jul 16, 2003 at 08:02:07AM -0700, Barry K. Nathan wrote:
> BTW, following my e-mail signature in this message is my .config. I
> guess the most notable setting is that CONFIG_SMP is disabled (i.e.,
> it's a UP compile).

Hmm. Well, ditching the strong typechecking would "fix" it, though
that's really only papering over it.

Okay, enough jabbering for me...


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

Subject: Re: [kpreempt-tech] Re: Oops in kernel 2.4.19-pre10-ac2-preempt
From: Robert Love <rml@tech9.net>
In-Reply-To: <20020620171652.GS25360@holomorphy.com>
References: <OF4C1E1763.D4BE6432-ON86256BDE.0055BDB6@hou.us.ray.com>
	<20020620171652.GS25360@holomorphy.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 20 Jun 2002 10:19:24 -0700
Message-Id: <1024593564.922.151.camel@sinai>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Mark_H_Johnson@Raytheon.com, kpreempt-tech@lists.sourceforge.net, linux-mm@kvack.org, Robert_Horton@Raytheon.com, James_P_Cassidy@Raytheon.com, Stanley_R_Allen@Raytheon.com
List-ID: <linux-mm.kvack.org>

On Thu, 2002-06-20 at 10:16, William Lee Irwin III wrote:

> The preemption cleanup cannot be done on 2.4 as there are no preemption
> disabling primitives available.

wli, if you send me a patch (or just tell me explicitly where to enable
and disable preemption) I will merge it into the 2.4-ac preempt
patches...

Thanks ;)

	Robert Love

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

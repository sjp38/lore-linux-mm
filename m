Date: Thu, 20 Jun 2002 10:16:52 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: Oops in kernel 2.4.19-pre10-ac2-preempt
Message-ID: <20020620171652.GS25360@holomorphy.com>
References: <OF4C1E1763.D4BE6432-ON86256BDE.0055BDB6@hou.us.ray.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <OF4C1E1763.D4BE6432-ON86256BDE.0055BDB6@hou.us.ray.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mark_H_Johnson@Raytheon.com
Cc: kpreempt-tech@lists.sourceforge.net, linux-mm@kvack.org, Robert_Horton@Raytheon.com, James_P_Cassidy@Raytheon.com, Stanley_R_Allen@Raytheon.com
List-ID: <linux-mm.kvack.org>

On Thu, Jun 20, 2002 at 11:01:22AM -0500, Mark_H_Johnson@Raytheon.com wrote:
> This was in reference to a port of rmap to the 2.5 kernel series, but I
> think this also applies to rmap on 2.4 as well. I highly recommend avoiding
> applying the kernel preemption patches to this kernel (2.4.19-pre10-ac2)
> until the preemption cleanup is completed on rmap. Since I have two
> different Oopses, I can't tell if the fix posted on the linux-mm is
> complete or not.

The preemption cleanup cannot be done on 2.4 as there are no preemption
disabling primitives available.


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

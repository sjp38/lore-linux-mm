Date: Thu, 10 Oct 2002 13:02:40 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: Fork timing numbers for shared page tables
Message-ID: <20021010200240.GV10722@holomorphy.com>
References: <167610000.1034278338@baldur.austin.ibm.com> <3DA5D893.CDD2407C@digeo.com> <175360000.1034279947@baldur.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <175360000.1034279947@baldur.austin.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmccr@us.ibm.com>
Cc: Andrew Morton <akpm@digeo.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Oct 10, 2002 at 02:59:07PM -0500, Dave McCracken wrote:
> I ran this test in three cases, 2.5.41, 2.5.41-mm2 without share, and
> 2.5.41-mm2 with share.
> Now for the results (all times are in ms):

Hrm, it'd be nice to see how nicely this does things for things like
500GB-sized processes on 64-bit boxen...


Any chance you could pass this test along for randomized benchmark
type stuff?



Thanks,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

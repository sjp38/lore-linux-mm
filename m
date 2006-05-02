Message-Id: <4t153d$t4guc@azsmga001.ch.intel.com>
From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: RE: [RFC 1/3] LVHPT - Fault handler modifications
Date: Tue, 2 May 2006 10:40:37 -0700
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
In-Reply-To: <20060502052551.8990.16410.sendpatchset@wagner.orchestra.cse.unsw.EDU.AU>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'Ian Wienand' <ianw@gelato.unsw.edu.au>, linux-ia64@vger.kernel.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Ian Wienand wrote on Monday, May 01, 2006 10:26 PM
> Firstly, we have stripped out common code in ivt.S into assembler
> macros in ivt-macro.S.  The comments before the macros should explain
> what each is doing.

I think at current state, it's way too early to extract out the common
code into macros, because for long format vhpt, the low level handler is
not even optimal.  And in the final form, it may not be the same as the
short format vhpt (OK, the linux page table walk will be the same, but
other part maybe not).

I would like to experiment with a few algorithms for lvhpt and best thing
to do in my opinion is to have parallel ivt.S (or ivt table to be precise).

- Ken

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

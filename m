Message-Id: <4t153d$t4bok@azsmga001.ch.intel.com>
From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: RE: [RFC 2/3] LVHPT - Setup LVHPT
Date: Tue, 2 May 2006 10:30:07 -0700
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
In-Reply-To: <B8E391BBE9FE384DAA4C5C003888BE6F066076B6@scsmsx401.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>, Ian Wienand <ianw@gelato.unsw.edu.au>, linux-ia64@vger.kernel.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Luck, Tony wrote on Tuesday, May 02, 2006 8:03 AM
> Thanks for keeping this alive.  Previous measurements on long
> format VHPT were mostly close to neutral performance-wise with
> short format ... 

This is a fairly gentle comments :-)  Digging up my result of performance
evaluation on database workload, the regression is quite big at 2.8%.  I'm
not that happy at all :-(


> so this is still waiting for the killer-app in
> the form of another patch that actually uses features of the
> long format VHPT to do something that can't easily be done by
> the short format

Database workload can be the potential killer-app ....


> to give me an incentive to complicate the code
> by adding yet another CONFIG option.  In fact, I'd prefer to see
> a compelling use case for long format so that it would be clear
> that the right thing to do would be to just remove short format
> and replace it with long format, but I don't expect that things
> will ever be that simple :-(


Boot time option to the rescue!  I have a patch that does just like that.
Though first order of business is to make lvhpt to perform on large
workload. If I recall correctly, lvhpt introduces performance regression
on certain components of cpu2000.

- Ken

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

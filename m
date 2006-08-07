Subject: Re: mempolicies: fix policy_zone check
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0608041717470.5792@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0608041646550.5573@schroedinger.engr.sgi.com>
	 <20060804170834.fe14ffe8.akpm@osdl.org>
	 <Pine.LNX.4.64.0608041717470.5792@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Mon, 07 Aug 2006 09:40:03 -0400
Message-Id: <1154958003.5181.4.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, ak@suse.de
List-ID: <linux-mm.kvack.org>

On Fri, 2006-08-04 at 17:18 -0700, Christoph Lameter wrote:
> On Fri, 4 Aug 2006, Andrew Morton wrote:
> 
>  > Do these patches fix Lee's "Regression in 2.6.18-rc2-mm1:  mbind() not binding"?
> 
> Yes. It only not binds for a two zone NUMA configuration though as 
> explained in the patch.

Ack.  I tested an earlier version of the fix for Christoph on Friday on
our platform but had to leave, incommunicado for the weekend, before his
final patch went out.

Lee



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

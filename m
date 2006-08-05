Date: Fri, 4 Aug 2006 17:18:24 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: mempolicies: fix policy_zone check
In-Reply-To: <20060804170834.fe14ffe8.akpm@osdl.org>
Message-ID: <Pine.LNX.4.64.0608041717470.5792@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0608041646550.5573@schroedinger.engr.sgi.com>
 <20060804170834.fe14ffe8.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, ak@suse.de
List-ID: <linux-mm.kvack.org>

On Fri, 4 Aug 2006, Andrew Morton wrote:

 > Do these patches fix Lee's "Regression in 2.6.18-rc2-mm1:  mbind() not binding"?

Yes. It only not binds for a two zone NUMA configuration though as 
explained in the patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

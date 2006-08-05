Date: Fri, 4 Aug 2006 17:08:34 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: mempolicies: fix policy_zone check
Message-Id: <20060804170834.fe14ffe8.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0608041646550.5573@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0608041646550.5573@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, ak@suse.de
List-ID: <linux-mm.kvack.org>

Do these patches fix Lee's "Regression in 2.6.18-rc2-mm1:  mbind() not binding"?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

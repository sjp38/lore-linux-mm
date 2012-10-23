Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 4DF086B0096
	for <linux-mm@kvack.org>; Mon, 22 Oct 2012 20:04:54 -0400 (EDT)
Date: Mon, 22 Oct 2012 17:04:52 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Major performance regressions in 3.7rc1/2
Message-Id: <20121022170452.cc8cc629.akpm@linux-foundation.org>
In-Reply-To: <20121022214502.0fde3adc@ilfaris>
References: <CAGPN=9Qx1JAr6CGO-JfoR2ksTJG_CLLZY_oBA_TFMzA_OSfiFg@mail.gmail.com>
	<20121022173315.7b0da762@ilfaris>
	<20121022214502.0fde3adc@ilfaris>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Julian Wollrath <julian.wollrath@stud.uni-goettingen.de>
Cc: Julian Wollrath <jwollrath@web.de>, Patrik Kullman <patrik.kullman@gmail.com>, linux-kernel <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

On Mon, 22 Oct 2012 21:45:02 +0200
Julian Wollrath <julian.wollrath@stud.uni-goettingen.de> wrote:

> Hello,
> 
> seems like I found the other bad commit. Everything, which means
> v3.7-rc*, works fine again with commit e6c509f85 (mm: use
> clear_page_mlock() in page_remove_rmap()) and commit 957f822a0 (mm,
> numa: reclaim from all nodes within reclaim distance) revoked.

Thanks.  Let's add some cc's.  Can you please describe your workload
and some estimate of the slowdown?

Patrik has also seen this and his description is

: I'm using an Asus Zenbook UX31E and have been installing all RCs in
: hope of improving the Wireless and Touchpad functionality.
: However, when trying 3.7 (rc1 and now rc2) I have major performance issues.
: 
: Easiest way to reproduce is to launch and play a game like Nexuiz,
: where the computer will lag, stutter and freeze until the machine is
: unresponsive within a couple of minutes.
: But an easy workload like browsing will also cause lags when switching
: tabs or redrawing a web page after a tab switch.
: Basically 3.7 is unusable for this machine.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

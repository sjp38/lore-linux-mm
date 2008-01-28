Date: Mon, 28 Jan 2008 12:16:40 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 0/4] [RFC] MMU Notifiers V1
In-Reply-To: <20080128194005.GE7233@v2.random>
Message-ID: <Pine.LNX.4.64.0801281216100.8965@schroedinger.engr.sgi.com>
References: <20080125055606.102986685@sgi.com> <20080125114229.GA7454@v2.random>
 <479DFE7F.9030305@qumranet.com> <20080128172521.GC7233@v2.random>
 <Pine.LNX.4.64.0801281103030.14003@schroedinger.engr.sgi.com>
 <20080128194005.GE7233@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Izik Eidus <izike@qumranet.com>, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Nick Piggin <npiggin@suse.de>, kvm-devel@lists.sourceforge.net, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Mon, 28 Jan 2008, Andrea Arcangeli wrote:

> With regard to the synchronize_rcu troubles they also be left to the
> notifier-user to solve. Certainly having the synchronize_rcu like in

Ahh. Ok.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

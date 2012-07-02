Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id DA2E06B006C
	for <linux-mm@kvack.org>; Mon,  2 Jul 2012 17:26:21 -0400 (EDT)
Received: by yhjj52 with SMTP id j52so5625801yhj.8
        for <linux-mm@kvack.org>; Mon, 02 Jul 2012 14:26:20 -0700 (PDT)
Date: Mon, 2 Jul 2012 14:26:17 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2] KSM: numa awareness sysfs knob
In-Reply-To: <20120630114053.GA3036@stainedmachine.redhat.com>
Message-ID: <alpine.DEB.2.00.1207021425110.24806@chino.kir.corp.google.com>
References: <1340970592-25001-1-git-send-email-pholasek@redhat.com> <20120629160510.GA10082@cmpxchg.org> <20120629163033.GA11327@stainedmachine.redhat.com> <20120629164706.GA7831@cmpxchg.org> <alpine.DEB.2.00.1206291526180.15200@chino.kir.corp.google.com>
 <20120630114053.GA3036@stainedmachine.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Holasek <pholasek@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Chris Wright <chrisw@sous-sol.org>, Izik Eidus <izik.eidus@ravellosystems.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Anton Arapov <anton@redhat.com>

On Sat, 30 Jun 2012, Petr Holasek wrote:

> The problem of the first patch/RFC was that merging algorithm was unstable
> and could merge pages with distance higher than was set up (described by 
> Nai Xia in RFC thread [1]). Sure, this instability could be solved, but for
> ksm pages shared by many other pages on different nodes we would have to still
> recalculate which page is "in the middle" and in case of change migrate it 
> between nodes every time when ksmd reach new shareable page or when some 
> sharing page is removed.
> 

Or you could simply refuse to ever merge any page that is identical to a 
page on a node with a distance greater than the threshold, i.e. never 
merge pages even under the threshold if a page exists on a node higher 
than the threshold.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

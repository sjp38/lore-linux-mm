Date: Tue, 2 Dec 2008 14:37:15 -0700
From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: [PATCH 3/4] add ksm kernel shared memory driver.
Message-ID: <20081202143715.1fa03879@bike.lwn.net>
In-Reply-To: <20081202212411.GG17607@acer.localdomain>
References: <1226888432-3662-1-git-send-email-ieidus@redhat.com>
	<1226888432-3662-2-git-send-email-ieidus@redhat.com>
	<1226888432-3662-3-git-send-email-ieidus@redhat.com>
	<1226888432-3662-4-git-send-email-ieidus@redhat.com>
	<20081128165806.172d1026@lxorguk.ukuu.org.uk>
	<20081202180724.GC17607@acer.localdomain>
	<20081202181333.38c7b421@lxorguk.ukuu.org.uk>
	<20081202212411.GG17607@acer.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chris Wright <chrisw@redhat.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Izik Eidus <ieidus@redhat.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, aarcange@redhat.com, avi@redhat.com, dlaor@redhat.com, kamezawa.hiroyu@jp.fujitsu.com, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Tue, 2 Dec 2008 13:24:11 -0800
Chris Wright <chrisw@redhat.com> wrote:

> > Using current known techniques. A random collision is just as bad
> > news.  
> 
> And, just to clarify, your concern would extend to any digest based
> comparison?  Or are you specifically concerned about sha1?

Wouldn't this issue just go away if the code simply compared the full
pages, rather than skipping the hashed 128 bytes at the beginning?
Given the cost of this whole operation (which, it seems, can involve
copying one of the pages before testing for equality), skipping the
comparison of 128 bytes seems like a bit of a premature optimization.

jon

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

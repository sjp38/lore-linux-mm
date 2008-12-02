Date: Tue, 2 Dec 2008 18:13:33 +0000
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH 3/4] add ksm kernel shared memory driver.
Message-ID: <20081202181333.38c7b421@lxorguk.ukuu.org.uk>
In-Reply-To: <20081202180724.GC17607@acer.localdomain>
References: <1226888432-3662-1-git-send-email-ieidus@redhat.com>
	<1226888432-3662-2-git-send-email-ieidus@redhat.com>
	<1226888432-3662-3-git-send-email-ieidus@redhat.com>
	<1226888432-3662-4-git-send-email-ieidus@redhat.com>
	<20081128165806.172d1026@lxorguk.ukuu.org.uk>
	<20081202180724.GC17607@acer.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chris Wright <chrisw@redhat.com>
Cc: Izik Eidus <ieidus@redhat.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, aarcange@redhat.com, avi@redhat.com, dlaor@redhat.com, kamezawa.hiroyu@jp.fujitsu.com, cl@linux-foundation.org, corbet@lwn.net
List-ID: <linux-mm.kvack.org>

On Tue, 2 Dec 2008 10:07:24 -0800
Chris Wright <chrisw@redhat.com> wrote:

> * Alan Cox (alan@lxorguk.ukuu.org.uk) wrote:
> > > +	r = !memcmp(old_digest, sha1_item->sha1val, SHA1_DIGEST_SIZE);
> > > +	mutex_unlock(&sha1_lock);
> > > +	if (r) {
> > > +		char *old_addr, *new_addr;
> > > +		old_addr = kmap_atomic(oldpage, KM_USER0);
> > > +		new_addr = kmap_atomic(newpage, KM_USER1);
> > > +		r = !memcmp(old_addr+PAGEHASH_LEN, new_addr+PAGEHASH_LEN,
> > > +			    PAGE_SIZE-PAGEHASH_LEN);
> > 
> > NAK - this isn't guaranteed to be robust so you could end up merging
> > different pages one provided by a malicious attacker.
> 
> I presume you're referring to the digest comparison.  While there's
> theoretical concern of hash collision, it's mitigated by hmac(sha1)
> so the attacker can't brute force for known collisions.

Using current known techniques. A random collision is just as bad news.

This code simply isn't fit for the kernel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

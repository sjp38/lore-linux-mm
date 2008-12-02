Date: Tue, 2 Dec 2008 10:07:24 -0800
From: Chris Wright <chrisw@redhat.com>
Subject: Re: [PATCH 3/4] add ksm kernel shared memory driver.
Message-ID: <20081202180724.GC17607@acer.localdomain>
References: <1226888432-3662-1-git-send-email-ieidus@redhat.com> <1226888432-3662-2-git-send-email-ieidus@redhat.com> <1226888432-3662-3-git-send-email-ieidus@redhat.com> <1226888432-3662-4-git-send-email-ieidus@redhat.com> <20081128165806.172d1026@lxorguk.ukuu.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081128165806.172d1026@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Izik Eidus <ieidus@redhat.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, aarcange@redhat.com, chrisw@redhat.com, avi@redhat.com, dlaor@redhat.com, kamezawa.hiroyu@jp.fujitsu.com, cl@linux-foundation.org, corbet@lwn.net
List-ID: <linux-mm.kvack.org>

* Alan Cox (alan@lxorguk.ukuu.org.uk) wrote:
> > +	r = !memcmp(old_digest, sha1_item->sha1val, SHA1_DIGEST_SIZE);
> > +	mutex_unlock(&sha1_lock);
> > +	if (r) {
> > +		char *old_addr, *new_addr;
> > +		old_addr = kmap_atomic(oldpage, KM_USER0);
> > +		new_addr = kmap_atomic(newpage, KM_USER1);
> > +		r = !memcmp(old_addr+PAGEHASH_LEN, new_addr+PAGEHASH_LEN,
> > +			    PAGE_SIZE-PAGEHASH_LEN);
> 
> NAK - this isn't guaranteed to be robust so you could end up merging
> different pages one provided by a malicious attacker.

I presume you're referring to the digest comparison.  While there's
theoretical concern of hash collision, it's mitigated by hmac(sha1)
so the attacker can't brute force for known collisions.

thanks,
-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

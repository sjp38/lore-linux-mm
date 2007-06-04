From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] Document Linux Memory Policy
Date: Mon, 4 Jun 2007 22:23:41 +0200
References: <1180467234.5067.52.camel@localhost> <1180976571.5055.24.camel@localhost> <Pine.LNX.4.64.0706041003040.23603@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0706041003040.23603@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200706042223.41681.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Gleb Natapov <glebn@voltaire.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

>
> The other issues will still remain! This is a fundamental change to the
> nature of memory policies. They are no longer under the control of the
> task but imposed from the outside. 

To be fair this can already happen with tmpfs (and hopefully soon hugetlbfs
again -- i plan to do some other work there anyways and will put 
that in too) . But with first touch it is relatively benign.

> If one wants to do this then the whole 
> scheme of memory policies needs to be reworked and rethought in order to
> be consistent and usable. For example you would need the ability to clear
> a memory policy.

That's just setting it to default.

Frankly I think this whole discussion is quite useless without discussing 
concrete use cases. So far I haven't heard any where this any file policy
would be a great improvement. Any further complication of the code which
is already quite complex needs a very good rationale.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Tue, 24 Apr 2007 13:52:44 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: 2.6.21-rc7-mm1 on test.kernel.org
In-Reply-To: <20070424134325.f71460af.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0704241351400.13382@schroedinger.engr.sgi.com>
References: <20070424130601.4ab89d54.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0704241320540.13005@schroedinger.engr.sgi.com>
 <20070424132740.e4bdf391.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0704241332090.13005@schroedinger.engr.sgi.com>
 <20070424134325.f71460af.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On Tue, 24 Apr 2007, Andrew Morton wrote:

> kexec requries 2MB alignment.  I think your old config would have just
> crashed.  Now you got told about it at compile time.

Old config worked great so far.

I compiled and booted 2.6.21-rc7-mm1 just fine. Nothing special apart from 
the usual problem with serial not accepting characters that we had for 
awhile now.

Could we get a .config?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Message-ID: <462E72A1.2090309@shadowen.org>
Date: Tue, 24 Apr 2007 22:12:01 +0100
From: Andy Whitcroft <apw@shadowen.org>
MIME-Version: 1.0
Subject: Re: 2.6.21-rc7-mm1 on test.kernel.org
References: <20070424130601.4ab89d54.akpm@linux-foundation.org> <Pine.LNX.4.64.0704241320540.13005@schroedinger.engr.sgi.com> <20070424132740.e4bdf391.akpm@linux-foundation.org> <Pine.LNX.4.64.0704241332090.13005@schroedinger.engr.sgi.com> <20070424134325.f71460af.akpm@linux-foundation.org> <Pine.LNX.4.64.0704241351400.13382@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0704241351400.13382@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Tue, 24 Apr 2007, Andrew Morton wrote:
> 
>> kexec requries 2MB alignment.  I think your old config would have just
>> crashed.  Now you got told about it at compile time.
> 
> Old config worked great so far.
> 
> I compiled and booted 2.6.21-rc7-mm1 just fine. Nothing special apart from 
> the usual problem with serial not accepting characters that we had for 
> awhile now.
> 
> Could we get a .config?

http://test.kernel.org/abat/84767/build/dotconfig

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

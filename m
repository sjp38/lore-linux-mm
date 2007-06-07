Message-ID: <4667B656.3080308@shadowen.org>
Date: Thu, 07 Jun 2007 08:40:06 +0100
From: Andy Whitcroft <apw@shadowen.org>
MIME-Version: 1.0
Subject: Re: SLUB: Use ilog2 instead of series of constant comparisons.
References: <Pine.LNX.4.64.0705211250410.27950@schroedinger.engr.sgi.com>	<20070606100817.7af24b74.akpm@linux-foundation.org>	<Pine.LNX.4.64.0706061053290.11553@schroedinger.engr.sgi.com>	<20070606131121.a8f7be78.akpm@linux-foundation.org>	<Pine.LNX.4.64.0706061326020.12565@schroedinger.engr.sgi.com> <20070606133432.2f3cb26a.akpm@linux-foundation.org> <46671C16.9080409@mbligh.org>
In-Reply-To: <46671C16.9080409@mbligh.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Bligh <mbligh@mbligh.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

Martin Bligh wrote:
> Andrew Morton wrote:
>> On Wed, 6 Jun 2007 13:28:40 -0700 (PDT) Christoph Lameter
>> <clameter@sgi.com> wrote:
>>
>>> On Wed, 6 Jun 2007, Andrew Morton wrote:
>>>
>>>>> There is also nothing special in CalcNTLMv2_partial_mac_key(). Two
>>>>> kmallocs of 33 bytes and 132 bytes each.
>>>> Yes, the code all looks OK.  I suspect this is another case of the
>>>> compiler
>>>> failing to remove unreachable stuff.
>>> Sigh.
>>>
>>> The patch was already in 2.6.22-rc3-mm1. Why did the patch pass the
>>> testing during that release cycle?
>>
>> Good question - don't know, sorry.
>>
>> I tried to build gcc-3.3.3 the other day.  Would you believe that
>> gcc-4.1.0
>> fails to compile gcc-3.3.3?
> 
> IIRC, the SUSE ones were customized anyway, so not sure that'd help you.
> Might do though.
> 
> There should be a sysinfo directory that lists stuff like gcc version,
> maybe it's not getting replicated to TKO though ... Nish or Andy,
> any chance you can take a look at the original copy of one of those
> jobs on the ABAT server?
> 
> I just fixed autotest, but I can't fix the old IBM code from here ;-)
> Anything else that'd be particularly handy to dump all the time?
> You can see what we're currently doing in the context of the diff
> below.
> 
> Index: sysinfo.py
> ===================================================================
> --- sysinfo.py  (revision 527)
> +++ sysinfo.py  (working copy)
> @@ -8,7 +8,7 @@
>  files = ['/proc/pci', '/proc/meminfo', '/proc/slabinfo', '/proc/version',
>         '/proc/cpuinfo', '/proc/cmdline']
>  # commands = ['lshw']        # this causes problems triggering CDROM
> drives
> -commands = ['uname -a', 'lspci -vvn']
> +commands = ['uname -a', 'lspci -vvn', 'gcc --version']
>  path = ['/usr/bin', '/bin']


Yep this is something we keep in the job, but apparently something we
don't push out to you.

Reading specs from /usr/lib/gcc-lib/powerpc-suse-linux/3.3.3/specs
Configured with: ../configure --enable-threads=posix --prefix=/usr
--with-local-prefix=/usr/local --infodir=/usr/share/info
--mandir=/usr/share/man --enable-languages=c,c++,f77,objc,java,ada
--disable-checking --libdir=/usr/lib --enable-libgcj
--with-gxx-include-dir=/usr/include/g++ --with-slibdir=/lib
--with-system-zlib --enable-shared --enable-__cxa_atexit
--host=powerpc-suse-linux --build=powerpc-suse-linux
--target=powerpc-suse-linux --enable-targets=powerpc64-suse-linux
--enable-biarch
Thread model: posix
gcc version 3.3.3 (SuSE Linux)

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
